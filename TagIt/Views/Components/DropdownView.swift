//
//  DropdownView.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-29.
//

import SwiftUI

struct DropdownView: View {
    var options:[String];
    @Binding var selectedOption:String?;
    var label:String;
    
    var body: some View {
        // Dropdown picker
        List{
            Picker(label, selection: $selectedOption) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option as String?)
                }
            }.pickerStyle(MenuPickerStyle())
        }
    }
}

#Preview {
    DropdownView(
        options: ["FreshCo Brentwood", "Safeway Market Mall", "Safeway North Hill"],
        selectedOption: .constant("FreshCo Brentwood"),
        label:"Supermarket"
    )
}
