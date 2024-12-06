import firebase_admin
from firebase_admin import credentials, firestore
import random

# Initialize Firebase Admin SDK
cred = credentials.Certificate("tagit-39035-firebase-adminsdk-hugo8-9c33455468.json")
firebase_admin.initialize_app(cred)

db = firestore.client()

def generate_votes_for_specific_deals(deals, all_user_ids):
    print("Generating Votes for specific deals...")
    votes = []
    used_votes = set()  # To prevent duplicate votes from the same user on the same item

    # Helper function to generate votes for an item
    def generate_votes_for_item(item_id, item_type, upvote_count, downvote_count, exclude_user_id):
        total_votes = upvote_count + downvote_count
        available_user_ids = [uid for uid in all_user_ids if uid != exclude_user_id]

        if total_votes > len(available_user_ids):
            print(f"Warning: Not enough unique users to generate votes for {item_type} {item_id}.")
            total_votes = len(available_user_ids)
            upvote_count = min(upvote_count, total_votes)
            downvote_count = total_votes - upvote_count

        random.shuffle(available_user_ids)
        vote_user_ids = available_user_ids[:total_votes]

        # Assign upvotes
        for uid in vote_user_ids[:upvote_count]:
            vote_key = (uid, item_id)
            if vote_key not in used_votes:
                used_votes.add(vote_key)
                votes.append({
                    "userId": uid,
                    "itemId": item_id,
                    "itemType": "deal",
                    "voteType": "upvote",
                })

        # Assign downvotes
        for uid in vote_user_ids[upvote_count:]:
            vote_key = (uid, item_id)
            if vote_key not in used_votes:
                used_votes.add(vote_key)
                votes.append({
                    "userId": uid,
                    "itemId": item_id,
                    "itemType": "deal",
                    "voteType": "downvote",
                })

    # Generate votes for each deal
    for deal in deals:
        item_id = deal.id
        deal_data = deal.to_dict()
        upvote_count = deal_data.get("upvote", 0)
        downvote_count = deal_data.get("downvote", 0)
        exclude_user_id = deal_data.get("userID", "")
        generate_votes_for_item(item_id, "deal", upvote_count, downvote_count, exclude_user_id)

    print(f"Generated {len(votes)} votes.")
    return votes

def populate_votes(votes, db):
    print("Populating Votes collection...")
    item_type_mapping = {
        "comment": 0,
        "deal": 1,
        "review": 2
    }

    for vote in votes:
        user_id = vote["userId"]
        item_id = vote["itemId"]
        item_type_str = vote["itemType"]
        vote_type = vote["voteType"]

        # Convert 'itemType' to integer
        item_type_int = item_type_mapping.get(item_type_str)
        if item_type_int is None:
            print(f"Invalid itemType '{item_type_str}' in vote: {vote}")
            continue

        # Construct document ID
        doc_id = f"{user_id}_{item_id}_{item_type_int}"

        vote_data = {
            "userId": user_id,
            "itemId": item_id,
            "itemType": item_type_int,
            "voteType": vote_type,
        }

        try:
            db.collection("Votes").document(doc_id).set(vote_data)
            print(f"Added Vote: {doc_id}")
        except Exception as e:
            print(f"Error adding Vote: {doc_id}: {e}")

# Your provided function to update UserProfile totals
def update_user_profile_totals(db):
    print("Updating UserProfile totals...")

    # Initialize a dictionary to store totals for each user
    user_totals = {}

    # Initialize totals to zero for all users
    users_ref = db.collection('UserProfile')
    users_docs = users_ref.stream()
    for user_doc in users_docs:
        user_id = user_doc.id
        user_totals[user_id] = {
            'totalDeals': 0,
            'totalComments': 0,
            'totalUpvotes': 0,
            'totalDownvotes': 0
        }

    # Calculate totalDeals for each user
    deals_ref = db.collection('Deals')
    deals_docs = deals_ref.stream()
    for deal_doc in deals_docs:
        deal_data = deal_doc.to_dict()
        user_id = deal_data.get('userID')
        if user_id in user_totals:
            user_totals[user_id]['totalDeals'] += 1

    # Calculate totalComments for each user
    comments_ref = db.collection('UserComments')
    comments_docs = comments_ref.stream()
    for comment_doc in comments_docs:
        comment_data = comment_doc.to_dict()
        user_id = comment_data.get('userID')
        if user_id in user_totals:
            user_totals[user_id]['totalComments'] += 1

    # Calculate totalUpvotes and totalDownvotes for each user based on Votes
    votes_ref = db.collection('Votes')
    votes_docs = votes_ref.stream()
    for vote_doc in votes_docs:
        vote_data = vote_doc.to_dict()
        vote_type = vote_data.get('voteType')
        item_type = vote_data.get('itemType')
        item_id = vote_data.get('itemId')

        # Get the owner of the item (Deal or Comment)
        if item_type == 1:  # Deal
            item_ref = db.collection('Deals').document(item_id)
        elif item_type == 0:  # Comment
            item_ref = db.collection('UserComments').document(item_id)
        else:
            continue  # Skip if itemType is not 'deal' or 'comment'

        item_doc = item_ref.get()
        if item_doc.exists:
            item_data = item_doc.to_dict()
            owner_user_id = item_data.get('userID')
            if owner_user_id in user_totals:
                if vote_type == 'upvote':
                    user_totals[owner_user_id]['totalUpvotes'] += 1
                elif vote_type == 'downvote':
                    user_totals[owner_user_id]['totalDownvotes'] += 1

    # Update UserProfile documents with the calculated totals
    for user_id, totals in user_totals.items():
        try:
            users_ref.document(user_id).update(totals)
            print(f"Updated UserProfile {user_id} with totals {totals}")
        except Exception as e:
            print(f"Error updating UserProfile {user_id}: {e}")

# Main function to generate votes and update totals
def main():
    # Retrieve deal10 and deal11 from the database
    deal_ids = ["deal10", "deal11"]
    deals = []
    for deal_id in deal_ids:
        deal_doc = db.collection("Deals").document(deal_id).get()
        if deal_doc.exists:
            deals.append(deal_doc)
            print(f"Retrieved {deal_id}")
        else:
            print(f"Deal {deal_id} does not exist in the database.")

    if not deals:
        print("No deals to process.")
        return

    # Collect all user IDs from UserProfile
    users_ref = db.collection('UserProfile')
    users_docs = users_ref.stream()
    all_user_ids = [user_doc.id for user_doc in users_docs]

    # Generate votes for the deals
    votes = generate_votes_for_specific_deals(deals, all_user_ids)

    # Populate the Votes collection
    populate_votes(votes, db)

    # Update UserProfile totals
    update_user_profile_totals(db)

if __name__ == "__main__":
    main()
