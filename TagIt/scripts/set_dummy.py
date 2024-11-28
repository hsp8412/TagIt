import firebase_admin 
from firebase_admin import credentials, firestore

# Initialize Firebase Admin SDK
SERVICE_ACCOUNT_PATH = "/Users/petertran/Downloads/tagit-39035-firebase-adminsdk-hugo8-9c33455468.json"
cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
firebase_admin.initialize_app(cred)

# Firestore database reference
db = firestore.client()

def initialize_data():
    collections = {
        "UserProfile" : [
            {
                "id": "user1",
                "username": "avocado_lover123",
                "email": "user1@example.com",
                "displayName": "Avocado Lover",
                "avatarURL": "https://example.com/avatar1.jpg",
                "score": 0,
                "savedDeals": [],
                "totalUpvotes": 0,
                "totalDownvotes": 0,
                "totalDeals": 0,
                "totalComments": 0,
                "rankingPoints": 0,
                "isDummy": True
            },
            {
                "id": "user2",
                "username": "baking_fan",
                "email": "user2@example.com",
                "displayName": "Baking Fan",
                "avatarURL": "https://example.com/avatar2.jpg",
                "score": 0,
                "savedDeals": [],
                "totalUpvotes": 0,
                "totalDownvotes": 0,
                "totalDeals": 0,
                "totalComments": 0,
                "rankingPoints": 0,
                "isDummy": True
            },
            {
                "id": "user3",
                "username": "banana_fanatic",
                "email": "user3@example.com",
                "displayName": "Banana Fanatic",
                "avatarURL": "https://example.com/avatar3.jpg",
                "score": 0,
                "savedDeals": [],
                "totalUpvotes": 0,
                "totalDownvotes": 0,
                "totalDeals": 0,
                "totalComments": 0,
                "rankingPoints": 0,
                "isDummy": True
            },
            {
                "id": "user4",
                "username": "banana_pref",
                "email": "user4@example.com",
                "displayName": "Banana Pref",
                "avatarURL": "https://example.com/avatar4.jpg",
                "score": 0,
                "savedDeals": [],
                "totalUpvotes": 0,
                "totalDownvotes": 0,
                "totalDeals": 0,
                "totalComments": 0,
                "rankingPoints": 0,
                "isDummy": True
            },
            {
                "id": "user5",
                "username": "berry_blast",
                "email": "user5@example.com",
                "displayName": "Berry Blast",
                "avatarURL": "https://example.com/avatar5.jpg",
                "score": 0,
                "savedDeals": [],
                "totalUpvotes": 0,
                "totalDownvotes": 0,
                "totalDeals": 0,
                "totalComments": 0,
                "rankingPoints": 0,
                "isDummy": True
            },
            {
                "id": "user6",
                "username": "brunch_fan",
                "email": "user6@example.com",
                "displayName": "Brunch Fan",
                "avatarURL": "https://example.com/avatar6.jpg",
                "score": 0,
                "savedDeals": [],
                "totalUpvotes": 0,
                "totalDownvotes": 0,
                "totalDeals": 0,
                "totalComments": 0,
                "rankingPoints": 0,
                "isDummy": True
            },
            {
                "id": "user7",
                "username": "budgetbuddy",
                "email": "user7@example.com",
                "displayName": "Budget Buddy",
                "avatarURL": "https://example.com/avatar7.jpg",
                "score": 0,
                "savedDeals": [],
                "totalUpvotes": 0,
                "totalDownvotes": 0,
                "totalDeals": 0,
                "totalComments": 0,
                "rankingPoints": 0,
                "isDummy": True
            },
            {
                "id": "user8",
                "username": "cake_baker",
                "email": "user8@example.com",
                "displayName": "Cake Baker",
                "avatarURL": "https://example.com/avatar8.jpg",
                "score": 0,
                "savedDeals": [],
                "totalUpvotes": 0,
                "totalDownvotes": 0,
                "totalDeals": 0,
                "totalComments": 0,
                "rankingPoints": 0,
                "isDummy": True
            },
            {
                "id": "user9",
                "username": "cereal_fanatic",
                "email": "user9@example.com",
                "displayName": "Cereal Fanatic",
                "avatarURL": "https://example.com/avatar9.jpg",
                "score": 0,
                "savedDeals": [],
                "totalUpvotes": 0,
                "totalDownvotes": 0,
                "totalDeals": 0,
                "totalComments": 0,
                "rankingPoints": 0,
                "isDummy": True
            },
            {
                "id": "user10",
                "username": "coffee_addict",
                "email": "user10@example.com",
                "displayName": "Coffee Addict",
                "avatarURL": "https://example.com/avatar10.jpg",
                "score": 0,
                "savedDeals": [],
                "totalUpvotes": 0,
                "totalDownvotes": 0,
                "totalDeals": 0,
                "totalComments": 0,
                "rankingPoints": 0,
                "isDummy": True
            },
            {
                "id": "user11",
                "username": "dairydelight",
                "email": "user11@example.com",
                "displayName": "Dairy Delight",
                "avatarURL": "https://example.com/avatar11.jpg",
                "score": 0,
                "savedDeals": [],
                "totalUpvotes": 0,
                "totalDownvotes": 0,
                "totalDeals": 0,
                "totalComments": 0,
                "rankingPoints": 0,
                "isDummy": True
            },
            {
                "id": "user12",
                "username": "egg_enthusiast",
                "email": "user12@example.com",
                "displayName": "Egg Enthusiast",
                "avatarURL": "https://example.com/avatar12.jpg",
                "score": 0,
                "savedDeals": [],
                "totalUpvotes": 0,
                "totalDownvotes": 0,
                "totalDeals": 0,
                "totalComments": 0,
                "rankingPoints": 0,
                "isDummy": True
            },
            {
                "id": "user13",
                "username": "egg_fan",
                "email": "user13@example.com",
                "displayName": "Egg Fan",
                "avatarURL": "https://example.com/avatar13.jpg",
                "score": 0,
                "savedDeals": [],
                "totalUpvotes": 0,
                "totalDownvotes": 0,
                "totalDeals": 0,
                "totalComments": 0,
                "rankingPoints": 0,
                "isDummy": True
            },
            {
                "id": "user14",
                "username": "fridge_full",
                "email": "user14@example.com",
                "displayName": "Fridge Full",
                "avatarURL": "https://example.com/avatar14.jpg",
                "score": 0,
                "savedDeals": [],
                "totalUpvotes": 0,
                "totalDownvotes": 0,
                "totalDeals": 0,
                "totalComments": 0,
                "rankingPoints": 0,
                "isDummy": True
            },
            {
                "id": "user15",
                "username": "fruitfanatic",
                "email": "user15@example.com",
                "displayName": "Fruit Fanatic",
                "avatarURL": "https://example.com/avatar15.jpg",
                "score": 0,
                "savedDeals": [],
                "totalUpvotes": 0,
                "totalDownvotes": 0,
                "totalDeals": 0,
                "totalComments": 0,
                "rankingPoints": 0,
                "isDummy": True
            },
            {
                "id": "user16",
                "username": "groceryguru",
                "email": "user16@example.com",
                "displayName": "Grocery Guru",
                "avatarURL": "https://example.com/avatar16.jpg",
                "score": 0,
                "savedDeals": [],
                "totalUpvotes": 0,
                "totalDownvotes": 0,
                "totalDeals": 0,
                "totalComments": 0,
                "rankingPoints": 0,
                "isDummy": True
            },
            {
                "id": "user17",
                "username": "guac_fanatic",
                "email": "user17@example.com",
                "displayName": "Guac Fanatic",
                "avatarURL": "https://example.com/avatar17.jpg",
                "score": 0,
                "savedDeals": [],
                "totalUpvotes": 0,
                "totalDownvotes": 0,
                "totalDeals": 0,
                "totalComments": 0,
                "rankingPoints": 0,
                "isDummy": True
            },
            {
                "id": "user18",
                "username": "healthy_harry",
                "email": "user18@example.com",
                "displayName": "Healthy Harry",
                "avatarURL": "https://example.com/avatar18.jpg",
                "score": 0,
                "savedDeals": [],
                "totalUpvotes": 0,
                "totalDownvotes": 0,
                "totalDeals": 0,
                "totalComments": 0,
                "rankingPoints": 0,
                "isDummy": True
            },
            {
                "id": "user19",
                "username": "hopeful_shopper",
                "email": "user19@example.com",
                "displayName": "Hopeful Shopper",
                "avatarURL": "https://example.com/avatar19.jpg",
                "score": 0,
                "savedDeals": [],
                "totalUpvotes": 0,
                "totalDownvotes": 0,
                "totalDeals": 0,
                "totalComments": 0,
                "rankingPoints": 0,
                "isDummy": True
            },
            {
                "id": "user20",
                "username": "hunter_gatherer",
                "email": "user20@example.com",
                "displayName": "Hunter Gatherer",
                "avatarURL": "https://example.com/avatar20.jpg",
                "score": 0,
                "savedDeals": [],
                "totalUpvotes": 0,
                "totalDownvotes": 0,
                "totalDeals": 0,
                "totalComments": 0,
                "rankingPoints": 0,
                "isDummy": True
            },
            {
                "id": "user21",
                "username": "muffin_maniac",
                "email": "user21@example.com",
                "displayName": "Muffin Maniac",
                "avatarURL": "https://example.com/avatar21.jpg",
                "score": 0,
                "savedDeals": [],
                "totalUpvotes": 0,
                "totalDownvotes": 0,
                "totalDeals": 0,
                "totalComments": 0,
                "rankingPoints": 0,
                "isDummy": True
            },
            {
                "id": "user22",
                "username": "organic_obsessed",
                "email": "user22@example.com",
                "displayName": "Organic Obsessed",
                "avatarURL": "https://example.com/avatar22.jpg",
                "score": 0,
                "savedDeals": [],
                "totalUpvotes": 0,
                "totalDownvotes": 0,
                "totalDeals": 0,
                "totalComments": 0,
                "rankingPoints": 0,
                "isDummy": True
            },
            {
                "id": "user23",
                "username": "pricehunter_pro",
                "email": "user23@example.com",
                "displayName": "Price Hunter Pro",
                "avatarURL": "https://example.com/avatar23.jpg",
                "score": 0,
                "savedDeals": [],
                "totalUpvotes": 0,
                "totalDownvotes": 0,
                "totalDeals": 0,
                "totalComments": 0,
                "rankingPoints": 0,
                "isDummy": True
            },
            {
                "id": "user24",
                "username": "smoothie_master",
                "email": "user24@example.com",
                "displayName": "Smoothie Master",
                "avatarURL": "https://example.com/avatar24.jpg",
                "score": 0,
                "savedDeals": [],
                "totalUpvotes": 0,
                "totalDownvotes": 0,
                "totalDeals": 0,
                "totalComments": 0,
                "rankingPoints": 0,
                "isDummy": True
            },
            {
                "id": "user25",
                "username": "soldout_sadface",
                "email": "user25@example.com",
                "displayName": "Sold Out Sadface",
                "avatarURL": "https://example.com/avatar25.jpg",
                "score": 0,
                "savedDeals": [],
                "totalUpvotes": 0,
                "totalDownvotes": 0,
                "totalDeals": 0,
                "totalComments": 0,
                "rankingPoints": 0,
                "isDummy": True
            },
            {
                "id": "user26",
                "username": "user1",
                "email": "user26@example.com",
                "displayName": "User 1",
                "avatarURL": "https://example.com/avatar26.jpg",
                "score": 0,
                "savedDeals": [],
                "totalUpvotes": 0,
                "totalDownvotes": 0,
                "totalDeals": 0,
                "totalComments": 0,
                "rankingPoints": 0,
                "isDummy": True
            },
            {
                "id": "user27",
                "username": "user2",
                "email": "user27@example.com",
                "displayName": "User 2",
                "avatarURL": "https://example.com/avatar27.jpg",
                "score": 0,
                "savedDeals": [],
                "totalUpvotes": 0,
                "totalDownvotes": 0,
                "totalDeals": 0,
                "totalComments": 0,
                "rankingPoints": 0,
                "isDummy": True
            },
            {
                "id": "user28",
                "username": "user3",
                "email": "user28@example.com",
                "displayName": "User 3",
                "avatarURL": "https://example.com/avatar28.jpg",
                "score": 0,
                "savedDeals": [],
                "totalUpvotes": 0,
                "totalDownvotes": 0,
                "totalDeals": 0,
                "totalComments": 0,
                "rankingPoints": 0,
                "isDummy": True
            },
            {
                "id": "user29",
                "username": "user4",
                "email": "user29@example.com",
                "displayName": "User 4",
                "avatarURL": "https://example.com/avatar29.jpg",
                "score": 0,
                "savedDeals": [],
                "totalUpvotes": 0,
                "totalDownvotes": 0,
                "totalDeals": 0,
                "totalComments": 0,
                "rankingPoints": 0,
                "isDummy": True
            },
            {
                "id": "user30",
                "username": "user5",
                "email": "user30@example.com",
                "displayName": "User 5",
                "avatarURL": "https://example.com/avatar30.jpg",
                "score": 0,
                "savedDeals": [],
                "totalUpvotes": 0,
                "totalDownvotes": 0,
                "totalDeals": 0,
                "totalComments": 0,
                "rankingPoints": 0,
                "isDummy": True
            },
            {
                "id": "user31",
                "username": "user6",
                "email": "user31@example.com",
                "displayName": "User 6",
                "avatarURL": "https://example.com/avatar31.jpg",
                "score": 0,
                "savedDeals": [],
                "totalUpvotes": 0,
                "totalDownvotes": 0,
                "totalDeals": 0,
                "totalComments": 0,
                "rankingPoints": 0,
                "isDummy": True
            }
        ],

        "Deals": [
            {
                "id": "deal1",
                "userID": "healthy_harry",
                "photoURL": "https://images.unsplash.com/photo-1512070904629-fa988dab2fe1?q=80&w=3870&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                "productText": "Avocado",
                "postText": "Perfectly ripe avocados on sale!",
                "price": 1.49,
                "location": "Save-On-Foods University District",
                "date": "2024-11-03",
                "commentIDs": ["comment1", "comment2", "comment3", "comment4"],
                "upvote": 30,
                "downvote": 2,
                "dateTime": firestore.SERVER_TIMESTAMP,
                "isDummy": True
            },
            {
                "id": "deal2",
                "userID": "fruitfanatic",
                "photoURL": "https://images.unsplash.com/photo-1727285100419-348edd55d403?q=80&w=3870&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                "productText": "Blueberries",
                "postText": "Fresh blueberries at a great price!",
                "price": 3.99,
                "location": "FreshCo Brentwood",
                "date": "2024-10-25",
                "commentIDs": ["comment5", "comment6", "comment7", "comment8"],
                "upvote": 20,
                "downvote": 1,
                "dateTime": firestore.SERVER_TIMESTAMP,
                "isDummy": True
            },
            {
                "id": "deal3",
                "userID": "groceryguru",
                "photoURL": "https://images.unsplash.com/photo-1510247548804-1a5c6f550b2d?q=80&w=3870&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                "productText": "Bananas",
                "postText": "Bananas at unbeatable prices!",
                "price": 0.49,
                "location": "Safeway Castleridge",
                "date": "2024-10-10",
                "commentIDs": ["comment9", "comment10", "comment11", "comment12"],
                "upvote": 50,
                "downvote": 0,
                "dateTime": firestore.SERVER_TIMESTAMP,
                "isDummy": True
            },
            {
                "id": "deal4",
                "userID": "dairydelight",
                "photoURL": "https://images.unsplash.com/photo-1506617420156-8e4536971650?q=80&w=4046&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                "productText": "Milk",
                "postText": "2% Milk for your morning cereal.",
                "price": 2.99,
                "location": "Brentwood Co-op",
                "date": firestore.SERVER_TIMESTAMP,
                "commentIDs": ["comment13", "comment14", "comment15", "comment16"],
                "upvote": 40,
                "downvote": 5,
                "dateTime": firestore.SERVER_TIMESTAMP,
                "isDummy": True
            },
            {
                "id": "deal5",
                "userID": "budgetbuddy",
                "photoURL": "https://plus.unsplash.com/premium_photo-1664305037196-003c3164a78c?q=80&w=3880&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                "productText": "Eggs",
                "postText": "Farm fresh eggs, limited time offer!",
                "price": 3.49,
                "location": "Superstore Country Hills",
                "date": firestore.SERVER_TIMESTAMP,
                "commentIDs": ["comment17", "comment18", "comment19", "comment20"],
                "upvote": 25,
                "downvote": 1,
                "dateTime": firestore.SERVER_TIMESTAMP,
                "isDummy": True
            }
        ],
"UserComments": [
    # Comments for deal1
    {
        "id": "comment1",
        "commentText": "This is an amazing deal on avocados!",
        "downvote": 0,
        "commentType": "deal",
        "upvote": 10,
        "dateTime": firestore.SERVER_TIMESTAMP,
        "itemID": "deal1",
        "userID": "avocado_lover123",
        "isDummy": True
    },
    {
        "id": "comment2",
        "commentText": "Wish I could get this price all year round.",
        "downvote": 1,
        "commentType": "deal",
        "upvote": 5,
        "dateTime": firestore.SERVER_TIMESTAMP,
        "itemID": "deal1",
        "userID": "pricehunter_pro",
        "isDummy": True
    },
    {
        "id": "comment3",
        "commentText": "My store was already out of stock :(",
        "downvote": 3,
        "commentType": "deal",
        "upvote": 2,
        "dateTime": firestore.SERVER_TIMESTAMP,
        "itemID": "deal1",
        "userID": "soldout_sadface",
        "isDummy": True
    },
    {
        "id": "comment4",
        "commentText": "Perfect for guacamole night!",
        "downvote": 0,
        "commentType": "deal",
        "upvote": 12,
        "dateTime": firestore.SERVER_TIMESTAMP,
        "itemID": "deal1",
        "userID": "guac_fanatic",
        "isDummy": True
    },

    # Comments for deal2
    {
        "id": "comment5",
        "commentText": "These blueberries are so sweet and fresh.",
        "downvote": 0,
        "commentType": "deal",
        "upvote": 8,
        "dateTime": firestore.SERVER_TIMESTAMP,
        "itemID": "deal2",
        "userID": "berry_blast",
        "isDummy": True
    },
    {
        "id": "comment6",
        "commentText": "Great price for organic blueberries!",
        "downvote": 0,
        "commentType": "deal",
        "upvote": 6,
        "dateTime": firestore.SERVER_TIMESTAMP,
        "itemID": "deal2",
        "userID": "organic_obsessed",
        "isDummy": True
    },
    {
        "id": "comment7",
        "commentText": "Perfect for baking muffins this weekend.",
        "downvote": 1,
        "commentType": "deal",
        "upvote": 4,
        "dateTime": firestore.SERVER_TIMESTAMP,
        "itemID": "deal2",
        "userID": "muffin_maniac",
        "isDummy": True
    },
    {
        "id": "comment8",
        "commentText": "Hope my store has enough stock for this deal.",
        "downvote": 2,
        "commentType": "deal",
        "upvote": 3,
        "dateTime": firestore.SERVER_TIMESTAMP,
        "itemID": "deal2",
        "userID": "hopeful_shopper",
        "isDummy": True
    },

    # Comments for deal3
    {
        "id": "comment9",
        "commentText": "Best price on bananas I've seen this year!",
        "downvote": 0,
        "commentType": "deal",
        "upvote": 15,
        "dateTime": firestore.SERVER_TIMESTAMP,
        "itemID": "deal3",
        "userID": "banana_fanatic",
        "isDummy": True
    },
    {
        "id": "comment10",
        "commentText": "Grabbed a bunch of these for smoothies!",
        "downvote": 0,
        "commentType": "deal",
        "upvote": 10,
        "dateTime": firestore.SERVER_TIMESTAMP,
        "itemID": "deal3",
        "userID": "smoothie_master",
        "isDummy": True
    },
    {
        "id": "comment11",
        "commentText": "Stock was limited, but worth the hunt.",
        "downvote": 1,
        "commentType": "deal",
        "upvote": 8,
        "dateTime": firestore.SERVER_TIMESTAMP,
        "itemID": "deal3",
        "userID": "hunter_gatherer",
        "isDummy": True
    },
    {
        "id": "comment12",
        "commentText": "I love bananas, but not when they're too ripe.",
        "downvote": 2,
        "commentType": "deal",
        "upvote": 5,
        "dateTime": firestore.SERVER_TIMESTAMP,
        "itemID": "deal3",
        "userID": "banana_pref",
        "isDummy": True
    },

    # Comments for deal4
    {
        "id": "comment13",
        "commentText": "Great deal on milk for cereal lovers!",
        "downvote": 0,
        "commentType": "deal",
        "upvote": 9,
        "dateTime": firestore.SERVER_TIMESTAMP,
        "itemID": "deal4",
        "userID": "cereal_fanatic",
        "isDummy": True
    },
    {
        "id": "comment14",
        "commentText": "Perfect for my morning coffee!",
        "downvote": 0,
        "commentType": "deal",
        "upvote": 6,
        "dateTime": firestore.SERVER_TIMESTAMP,
        "itemID": "deal4",
        "userID": "coffee_addict",
        "isDummy": True
    },
    {
        "id": "comment15",
        "commentText": "My fridge is fully stocked now!",
        "downvote": 1,
        "commentType": "deal",
        "upvote": 7,
        "dateTime": firestore.SERVER_TIMESTAMP,
        "itemID": "deal4",
        "userID": "fridge_full",
        "isDummy": True
    },
    {
        "id": "comment16",
        "commentText": "Fresh milk is a must-have for baking.",
        "downvote": 0,
        "commentType": "deal",
        "upvote": 8,
        "dateTime": firestore.SERVER_TIMESTAMP,
        "itemID": "deal4",
        "userID": "baking_fan",
        "isDummy": True
    },

    {
        "id": "comment17",
        "commentText": "Farm fresh eggs taste amazing!",
        "downvote": 0,
        "commentType": "deal",
        "upvote": 12,
        "dateTime": firestore.SERVER_TIMESTAMP,
        "itemID": "deal5",
        "userID": "egg_enthusiast",
        "isDummy": True
    },
    {
        "id": "comment18",
        "commentText": "Perfect for weekend brunch!",
        "downvote": 0,
        "commentType": "deal",
        "upvote": 9,
        "dateTime": firestore.SERVER_TIMESTAMP,
        "itemID": "deal5",
        "userID": "brunch_fan",
        "isDummy": True
    },
    {
        "id": "comment19",
        "commentText": "Best eggs for baking cakes!",
        "downvote": 1,
        "commentType": "deal",
        "upvote": 7,
        "dateTime": firestore.SERVER_TIMESTAMP,
        "itemID": "deal5",
        "userID": "cake_baker",
        "isDummy": True
    },
    {
        "id": "comment20",
        "commentText": "Fresh and affordable eggs.",
        "downvote": 0,
        "commentType": "deal",
        "upvote": 10,
        "dateTime": firestore.SERVER_TIMESTAMP,
        "itemID": "deal5",
        "userID": "egg_fan",
        "isDummy": True
    }
],
"Votes": [
    {
        "id": "vote1",  
        "userId": "hunter_gatherer",
        "itemId": "deal1",
        "itemType": "deal",
        "voteType": "upvote",
        "dateTime": firestore.SERVER_TIMESTAMP,  
        "isDummy": True
    },
    {
        "id": "vote2",
        "userId": "berry_blast",
        "itemId": "deal1",
        "itemType": "deal",
        "voteType": "downvote",
        "dateTime": firestore.SERVER_TIMESTAMP,
        "isDummy": True
    },
    {
        "id": "vote3",
        "userId": "groceryguru",
        "itemId": "deal2",
        "itemType": "deal",
        "voteType": "upvote",
        "dateTime": firestore.SERVER_TIMESTAMP,
        "isDummy": True
    },
    {
        "id": "vote4",
        "userId": "organic_obsessed",
        "itemId": "deal3",
        "itemType": "deal",
        "voteType": "upvote",
        "dateTime": firestore.SERVER_TIMESTAMP,
        "isDummy": True
    },
    {
        "id": "vote5",
        "userId": "pricehunter_pro",
        "itemId": "deal4",
        "itemType": "deal",
        "voteType": "downvote",
        "dateTime": firestore.SERVER_TIMESTAMP,
        "isDummy": True
    },
    {
        "id": "vote6",
        "userId": "smoothie_master",
        "itemId": "deal5",
        "itemType": "deal",
        "voteType": "upvote",
        "dateTime": firestore.SERVER_TIMESTAMP,
        "isDummy": True
    }
]
    }
    # Step 1: Populate UserProfile collection and create a mapping
    print("Populating UserProfile collection...")
    user_profile_map = {}  # Map usernames to IDs
    for user_profile in collections["UserProfile"]:
        try:
            db.collection("UserProfile").document(user_profile["id"]).set(user_profile)
            user_profile_map[user_profile["username"]] = user_profile["id"]
            print(f"Added UserProfile: {user_profile['id']}")
        except Exception as e:
            print(f"Error adding UserProfile: {e}")

    # Step 2: Populate Deals collection with resolved userID
    print("Populating Deals collection...")
    for deal in collections["Deals"]:
        username = deal["userID"]  # Original username in the Deals data
        resolved_id = user_profile_map.get(username)  # Resolve to UserProfile ID
        if resolved_id:
            deal["userID"] = resolved_id  # Replace username with resolved ID
            deal["username"] = username  # Optionally keep the username for display
        else:
            print(f"Warning: No UserProfile found for userID {username}")
            deal["userID"] = "unknown"  # Default value for unresolved users
            deal["username"] = "Unknown User"

        try:
            db.collection("Deals").document(deal["id"]).set(deal)
            print(f"Added Deal: {deal['id']} with userID {deal['userID']}")
        except Exception as e:
            print(f"Error adding Deal: {e}")

    # Step 3: Populate UserComments collection with resolved userID
    print("Populating UserComments collection...")
    for comment in collections["UserComments"]:
        username = comment["userID"]  # Original username in the UserComments data
        resolved_id = user_profile_map.get(username)  # Resolve to UserProfile ID
        if resolved_id:
            comment["userID"] = resolved_id  # Replace username with resolved ID
        else:
            print(f"Warning: No UserProfile found for userID {username}")
            comment["userID"] = "unknown"  # Default value for unresolved users

        try:
            db.collection("UserComments").document(comment["id"]).set(comment)
            print(f"Added UserComment: {comment['id']} with userID {comment['userID']}")
        except Exception as e:
            print(f"Error adding UserComment: {e}")

    print("Data initialization completed.")

initialize_data()
