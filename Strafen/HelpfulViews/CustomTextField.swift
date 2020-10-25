//
//  CustomTextField.swift
//  Strafen
//
//  Created by Steven on 28.06.20.
//

import SwiftUI

struct _DefaultErrorType: ErrorMessageType {
    var message: String = ""
}

/// Text Field with custom Design
struct CustomTextField<ErrorType>: View where ErrorType: ErrorMessageType {
    
    /// Placeholder of Text field
    let title: String
    
    /// Binding of input text
    @Binding var text: String
    
    /// Binding containing if keyboard is on screen
    @Binding var keyboardOnScreen: Bool
    
    /// Handler execuded after keyboard dismisses
    let completionHandler: (() -> ())?
    
    /// Keyboard type
    let keyboardType: UIKeyboardType
    
    /// Error message type
    @Binding var errorMessageType: ErrorType?
    
    /// Textfield size
    private var textFieldSize: (width: CGFloat?, height: CGFloat?)
    
    /// Show error message
    private var showErrorMessage = true
    
    init(_ title: String, text: Binding<String>, keyboardType: UIKeyboardType = .default, keyboardOnScreen: Binding<Bool> = .constant(false), errorType: Binding<ErrorType?>, completionHandler: (() -> ())? = nil) {
        self.title = title
        self._text = text
        self._keyboardOnScreen = keyboardOnScreen
        self.completionHandler = completionHandler
        self.keyboardType = keyboardType
        self._errorMessageType = errorType
    }
    
    var body: some View {
        VStack(spacing: 5) {
            ZStack {
                
                // Outline
                Outline()
                    .strokeColor(errorMessageType.map { _ in Color.custom.red })
                
                // Text Field
                TextField(title, text: $text) { appears in
                    withAnimation {
                        keyboardOnScreen = appears
                    }
                    if let completionHandler = completionHandler, !appears {
                        completionHandler()
                    }
                } onCommit: {}
                    .foregroundColor(errorMessageType.map { _ in Color.custom.red } ?? .textColor)
                    .font(.text(20))
                    .lineLimit(1)
                    .padding(.horizontal, 10)
                    .multilineTextAlignment(.center)
            }.keyboardType(keyboardType)
                .frame(width: textFieldSize.width, height: textFieldSize.height)
            
            // Error message
            if showErrorMessage {
                ErrorMessages(errorType: $errorMessageType)
            }
        }
    }
    
    /// Set textfield size
    func textFieldSize(width: CGFloat? = nil, height: CGFloat? = nil) -> CustomTextField {
        var textfield = self
        textfield.textFieldSize = (width: width, height: height)
        return textfield
    }
    
    /// Set textfield size
    func textFieldSize(size: CGSize) -> CustomTextField {
        var textfield = self
        textfield.textFieldSize = (width: size.width, height: size.height)
        return textfield
    }
    
    /// Show error message
    func showErrorMessage(_ show: Bool) -> CustomTextField {
        var textField = self
        textField.showErrorMessage = show
        return textField
    }
}

extension CustomTextField where ErrorType == _DefaultErrorType {
    init(_ title: String, text: Binding<String>, keyboardType: UIKeyboardType = .default, keyboardOnScreen: Binding<Bool> = .constant(false), completionHandler: (() -> ())? = nil) {
        self.title = title
        self._text = text
        self._keyboardOnScreen = keyboardOnScreen
        self.completionHandler = completionHandler
        self.keyboardType = keyboardType
        self._errorMessageType = .constant(nil)
    }
}

/// Secure Field with custom Design
struct CustomSecureField<ErrorType>: View where ErrorType: ErrorMessageType {
    
    /// Binding of input text
    @Binding var text: String
    
    /// Placeholder
    let placeholder: String
    
    /// Binding containing if keyboard is on screen
    @Binding var keyboardOnScreen: Bool
    
    /// Error message type
    @Binding var errorMessageType: ErrorType?
    
    /// Handler execuded after keyboard dismisses
    let completionHandler: (() -> ())?
    
    /// Textfield size
    private var textFieldSize: (width: CGFloat?, height: CGFloat?)
    
    init(text: Binding<String>, placeholder: String, keyboardOnScreen: Binding<Bool> = .constant(false), errorType: Binding<ErrorType?>, completionHandler: (() -> ())? = nil) {
        self.placeholder = placeholder
        self._text = text
        self._keyboardOnScreen = keyboardOnScreen
        self.completionHandler = completionHandler
        self._errorMessageType = errorType
    }
    
    var body: some View {
        VStack(spacing: 5) {
            ZStack {
                
                // Outline
                Outline()
                    .strokeColor(errorMessageType.map { _ in Color.custom.red })
                
                // Text Field
                UISecureField(placeholder: placeholder, text: $text, keyboardOnScreen: $keyboardOnScreen, completionHandler: completionHandler)
                    .foregroundColor(.textColor)
                    .font(.text(20))
                    .lineLimit(1)
                    .padding(.horizontal, 10)
                    .multilineTextAlignment(.center)
            }.frame(width: textFieldSize.width, height: textFieldSize.height)
            
            // Error message
            ErrorMessages(errorType: $errorMessageType)
        }
    }
    
    /// Set textfield size
    func textFieldSize(width: CGFloat? = nil, height: CGFloat? = nil) -> CustomSecureField {
        var textfield = self
        textfield.textFieldSize = (width: width, height: height)
        return textfield
    }
    
    /// Set textfield size
    func textFieldSize(size: CGSize) -> CustomSecureField {
        var textfield = self
        textfield.textFieldSize = (width: size.width, height: size.height)
        return textfield
    }
}

extension CustomSecureField where ErrorType == _DefaultErrorType {
    init(text: Binding<String>, placeholder: String, keyboardOnScreen: Binding<Bool> = .constant(false), completionHandler: (() -> ())? = nil) {
        self.placeholder = placeholder
        self._text = text
        self._keyboardOnScreen = keyboardOnScreen
        self.completionHandler = completionHandler
        self._errorMessageType = .constant(nil)
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
        textField.clearButtonMode = .always
        textField.clearsOnBeginEditing = true
        return textField
    }
    
    /// update View
    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<UISecureField>) {
        uiView.text = text
    }
}
