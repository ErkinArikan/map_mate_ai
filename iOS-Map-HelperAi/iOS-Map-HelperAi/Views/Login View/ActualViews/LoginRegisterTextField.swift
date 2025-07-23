//
//  LoginRegisterTextField.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 7.12.2024.
//

import SwiftUI

struct LoginRegisterTextField: View {
    var header:String?
    @Binding var  textFieldText:String
    @Environment(\.colorScheme) private var colorScheme
    var image:String?
    @Binding var isTapped:Bool
    @FocusState private var isTappedFocused: Bool // Focus state for TextField
    @Binding var count:Int
    
    @EnvironmentObject var languageManager:LanguageManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4){
            Text(header?.addLocalizableString(str: languageManager.language) ?? "Example Header".addLocalizableString(str: languageManager.language))
                .font(.system(size: 16))
                .fontWeight(.semibold)
                .foregroundColor(Color.hex("0C7B93"))
                .padding(.leading,18)
               
            
            HStack {
                TextField("", text: $textFieldText)
                    .placeholder(when: textFieldText.isEmpty) {
                        Text("example name".addLocalizableString(str: languageManager.language)).font(.system(size: 14)).foregroundColor(colorScheme == .dark ? Color.hex("0C7B93").opacity(0.8): Color.hex("0C7B93"))
                        
                    }
                    .foregroundStyle(Color("myDark"))
                    .focused($isTappedFocused) // Bind focus state
                    .onChange(of: isTappedFocused) { old,newValue in
                        count += 1
                        print("count \(count)")
                        isTapped = newValue
                        if newValue {
                            print("isTapped: \(isTapped)")
                        }else {
                            print("isTapped: \(isTapped)")
                        }
                        
                    }
                  
                Image(systemName: image ?? "person")
                    .foregroundColor(colorScheme == .dark ? Color.hex("0C7B93").opacity(0.8): Color.hex("0C7B93"))
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done".addLocalizableString(str: languageManager.language)) { hideKeyboard() }
                
                }
            }
            .frame(height:12)
             .padding()
             .background(Color("BabyBlue"))
            .cornerRadius(30)
            .contentShape(Rectangle()) // Tüm alanı dokunulabilir yap
           
        }
    }
}

#Preview {
    LoginRegisterTextField(textFieldText: .constant(""), isTapped: .constant(false), count: .constant(1))
}


struct PasswordTextField:View {
    @Binding var password:String
    @State var isPasswordVisible:Bool = false
    @Environment(\.colorScheme) private var colorScheme
    @Binding var isPasswordTapped:Bool
    @FocusState private var isPasswordTappedFocused: Bool // Focus state for TextField
    @EnvironmentObject var languageManager:LanguageManager
    var body: some View {
        VStack(alignment: .leading, spacing: 4){
        Text("Password".addLocalizableString(str: languageManager.language))
            .font(.system(size: 16))
            .fontWeight(.semibold)
            .foregroundColor(Color.hex("0C7B93"))
            .padding(.leading,18)
        
        HStack {
            if isPasswordVisible {
                TextField("", text: $password)
                    
                    .placeholder(when: password.isEmpty) {
                        Text("example password".addLocalizableString(str: languageManager.language)).font(.system(size: 14)).foregroundColor(colorScheme == .dark ? Color.hex("0C7B93").opacity(0.8): Color.hex("0C7B93").opacity(colorScheme == .dark ? 0.5:0.5))
                            
                    }
                    .foregroundStyle(Color("myDark"))
                    .focused($isPasswordTappedFocused) // Bind focus state
                    .onChange(of: isPasswordTappedFocused) { old,newValue in
                        isPasswordTapped = newValue
                        if newValue {
                            print("isTapped: \(isPasswordTapped)")
                        }else {
                            print("isTapped: \(isPasswordTapped)")
                        }
                        
                    }
                    
            } else {
                SecureField("", text: $password)
                   
                    .placeholder(when: password.isEmpty) {
                            Text("********").font(.system(size: 14)).foregroundColor(colorScheme == .dark ? Color.hex("0C7B93").opacity(0.8): Color.hex("0C7B93"))
                    }
                    .foregroundStyle(Color("myDark"))
                    .focused($isPasswordTappedFocused) // Bind focus state
                    .onChange(of: isPasswordTappedFocused) { old,newValue in
                        isPasswordTapped = newValue
                        if newValue {
                            print("isTapped: \(isPasswordTapped)")
                        }else {
                            print("isTapped: \(isPasswordTapped)")
                        }
                        
                    }
                   
            }
            
            Button(action: {
                isPasswordVisible.toggle()
            }) {
                Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                    .foregroundColor(colorScheme == .dark ? Color.hex("0C7B93").opacity(0.8): Color.hex("0C7B93"))
            }
        }
        .frame(height:12)
        .padding()
        .background(Color("BabyBlue"))
        .cornerRadius(30)
        .contentShape(Rectangle()) // Tüm alanı dokunulabilir yap
       
    }
    }
}


struct RegisterNameTextField: View {
    var header:String?
    @Binding var  textFieldText:String
    @Environment(\.colorScheme) private var colorScheme
    var image:String?
    @Binding var isTapped:Bool
    @FocusState private var isTappedFocused: Bool // Focus state for TextField
    @Binding var count:Int
    @EnvironmentObject var languageManager:LanguageManager
    var body: some View {
        VStack(alignment: .leading, spacing: 4){
            Text(header?.addLocalizableString(str: languageManager.language) ?? "Example Header")
                .font(.system(size: 16))
                .fontWeight(.semibold)
                .foregroundColor(Color.hex("0C7B93"))
                .padding(.leading,18)
               
            
            HStack {
                TextField("", text: $textFieldText)
                    .placeholder(when: textFieldText.isEmpty) {
                        Text("example name").font(.system(size: 14)).foregroundColor(colorScheme == .dark ? Color.hex("0C7B93").opacity(0.8): Color.hex("0C7B93"))
                        
                    }
                    .foregroundStyle(Color("myDark"))
                    .focused($isTappedFocused) // Bind focus state
                    .onChange(of: isTappedFocused) { old,newValue in
                        count += 1
                        print("count \(count)")
                        isTapped = newValue
                        if newValue {
                            print("isTapped: \(isTapped)")
                        }else {
                            print("isTapped: \(isTapped)")
                        }
                        
                    }
                  
                Image(systemName: image ?? "person")
                    .foregroundColor(colorScheme == .dark ? Color.hex("0C7B93").opacity(0.8): Color.hex("0C7B93"))
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done".addLocalizableString(str: languageManager.language)) { hideKeyboard() }
                
                }
            }
            .frame(height:12)
             .padding()
             .background(Color("BabyBlue"))
            .cornerRadius(30)
            .contentShape(Rectangle()) // Tüm alanı dokunulabilir yap
           
        }
    }
}
