//
//  CustomTextField.swift
//  Strafen
//
//  Created by Steven on 28.06.20.
//

import SwiftUI

/// Text Field with custom Design
struct CustomTextField: View {
    
    /// Placeholder of Text field
    let title: String
    
    /// Binding of input text
    @Binding var text: String
    
    /// Binding containing if keyboard is on screen
    @Binding var keyboardOnScreen: Bool
    
    /// Handler execuded after keyboard dismisses
    let completionHandler: (() -> ())?
    
    init(_ title: String, text: Binding<String>, keyboardOnScreen: Binding<Bool>, completionHandler: (() -> ())? = nil) {
        self.title = title
        self._text = text
        self._keyboardOnScreen = keyboardOnScreen
        self.completionHandler = completionHandler
    }
    
    var body: some View {
        ZStack {
            
            // Outline
            Outline()
            
            // Text Field
            TextField(title, text: $text) { appears in
                withAnimation {
                    keyboardOnScreen = appears
                }
                if let completionHandler = completionHandler, !appears {
                    completionHandler()
                }
            } onCommit: {}.foregroundColor(Color.textColor)
                .font(.text(20))
                .lineLimit(1)
                .padding(.horizontal, 10)
                .multilineTextAlignment(.center)
        }
    }
}

/// Secure Field with custom Design
struct CustomSecureField: View {
    
    /// Binding of input text
    @Binding var text: String
    
    /// Placeholder
    let placeholder: String
    
    /// Binding containing if keyboard is on screen
    @Binding var keyboardOnScreen: Bool
    
    /// Handler execuded after keyboard dismisses
    let completionHandler: (() -> ())?
    
    init(text: Binding<String>, placeholder: String, keyboardOnScreen: Binding<Bool>, completionHandler: (() -> ())? = nil) {
        self.placeholder = placeholder
        self._text = text
        self._keyboardOnScreen = keyboardOnScreen
        self.completionHandler = completionHandler
    }
    
    var body: some View {
        ZStack {
            
            // Outline
            Outline()
            
            // Text Field
            UISecureField(placeholder: placeholder, text: $text, keyboardOnScreen: $keyboardOnScreen, completionHandler: completionHandler)
                .foregroundColor(Color.textColor)
                .font(.text(20))
                .lineLimit(1)
                .padding(.horizontal, 10)
                .multilineTextAlignment(.center)
        }
    }
}

/// UIViewRepresentable of UISecureField for password text field
struct UISecureField: UIViewRepresentable {
    
    /// Placeholder
    let placeholder: String
    
    /// Input text
    @Binding var text: String
    
    /// true if keyboard is on screen
    @Binding var keyboardOnScreen: Bool
    
    /// Handler execuded after keyboard dismisses
    let completionHandler: (() -> ())?
    
    /// UISecureField Coordinator
    class Coordinator: NSObject, UITextFieldDelegate {
        
        /// Input text
        @Binding var text: String
        
        /// true if keyboard is on screen
        @Binding var keyboardOnScreen: Bool
        
        /// Handler execuded after keyboard dismisses
        let completionHandler: (() -> ())?
        
        init(text: Binding<String>, keyboardOnScreen: Binding<Bool>, completionHandler: (() -> ())?) {
            _text = text
            _keyboardOnScreen = keyboardOnScreen
            self.completionHandler = completionHandler
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if let text = textField.text {
                self.text = text
            }
            return true
        }
        
        func textFieldShouldClear(_ textField: UITextField) -> Bool {
            text = ""
            return true
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            return true
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            withAnimation {
                keyboardOnScreen = true
            }
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            if let text = textField.text {
                self.text = text
            }
            withAnimation {
                keyboardOnScreen = false
            }
            if let completionHandler = completionHandler {
                completionHandler()
            }
        }
    }
    
    /// make Coordinator
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, keyboardOnScreen: $keyboardOnScreen, completionHandler: completionHandler)
    }
    
    /// make View
    func makeUIView(context: UIViewRepresentableContext<UISecureField>) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.autocapitalizationType = .none
        textField.isSecureTextEntry = true
        textField.passwordRules = UITextInputPasswordRules(descriptor: "required: upper; required: lower; required: digit; max-consecutive: 2; minlength: 8;")
        textField.placeholder = placeholder
        textField.font = UIFont(name: "Futura-Medium", size: 20)
        textField.textColor = UIColor(red: 112 / 255, green: 112 / 255, blue: 112 / 255, alpha: 1)
        textField.textAlignment = .center
        return textField
    }
    
    /// update View
    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<UISecureField>) {
        uiView.text = text
    }
}
