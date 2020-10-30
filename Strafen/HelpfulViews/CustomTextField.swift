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
    private var title: String = "Placeholder"
    
    /// Binding of input text
    private var text: Binding<String> = .constant("")
    
    /// Binding containing if keyboard is on screen
    private var keyboardOnScreen: Binding<Bool>? = nil
    
    /// Handler execuded after keyboard dismisses
    private var completionHandler: (() -> Void)? = nil
    
    /// Keyboard type
    private var keyboardType: UIKeyboardType = .default
    
    /// Error message type
    private var errorMessages: Binding<ErrorMessages?> = .constant(nil)
    
    /// Textfield size
    private var textFieldSize: (width: CGFloat?, height: CGFloat?)
    
    /// Show error message
    private var showErrorMessage = true
    
    /// Deprecated init with title, text, keyboardType, keyboardOnScreen and completionHandler
    @available(*, deprecated, message: "replaced by init() and view modifiers")
    init(_ title: String, text: Binding<String>, keyboardType: UIKeyboardType = .default, keyboardOnScreen: Binding<Bool> = .constant(false), completionHandler: (() -> ())? = nil) {
        self.title = title
        self.text = text
        self.keyboardOnScreen = keyboardOnScreen
        self.completionHandler = completionHandler
        self.keyboardType = keyboardType
    }
    
    /// Init with default values
    public init() {}
    
    public var body: some View {
        VStack(spacing: 5) {
            ZStack {
                
                // Outline
                Outline()
                    .strokeColor(errorMessages.wrappedValue.map { _ in Color.custom.red })
                    .lineWidth(errorMessages.wrappedValue.map { _ in CGFloat(2) })
                
                // Text Field
                TextField(title, text: text) { appears in
                    withAnimation {
                        keyboardOnScreen?.wrappedValue = appears
                    }
                    if let completionHandler = completionHandler, !appears {
                        completionHandler()
                    }
                } onCommit: {}
                .foregroundColor(errorMessages.wrappedValue.map { _ in Color.custom.red } ?? .textColor)
                    .font(.text(20))
                    .lineLimit(1)
                    .padding(.horizontal, 10)
                    .multilineTextAlignment(.center)
            }.keyboardType(keyboardType)
                .frame(width: textFieldSize.width, height: textFieldSize.height)
            
            // Error message
            if showErrorMessage {
                ErrorMessageView(errorMessages: errorMessages)
            }
        }.animation(.default)
    }
    
    /// Set textfield size
    public func textFieldSize(width: CGFloat? = nil, height: CGFloat? = nil) -> CustomTextField {
        var textfield = self
        textfield.textFieldSize = (width: width, height: height)
        return textfield
    }
    
    /// Set textfield size
    public func textFieldSize(size: CGSize) -> CustomTextField {
        var textfield = self
        textfield.textFieldSize = (width: size.width, height: size.height)
        return textfield
    }
    
    /// Show error message
    public func showErrorMessage(_ show: Bool) -> CustomTextField {
        var textField = self
        textField.showErrorMessage = show
        return textField
    }
    
    /// Set title
    public func title(_ title: String) -> CustomTextField {
        var textField = self
        textField.title = title
        return textField
    }
    
    /// Set text binding
    public func textBinding(_ text: Binding<String>) -> CustomTextField {
        var textField = self
        textField.text = text
        return textField
    }
    
    /// Set keyboard type
    public func keyboardType(_ keyboardType: UIKeyboardType) -> CustomTextField {
        var textField = self
        textField.keyboardType = keyboardType
        return textField
    }
    
    /// Deprecated set keyboard on screen binding
    @available(*, deprecated, message: "use keyboardAdaptive view modifier instead")
    public func keyboardOnScreen(_ keyboardOnScreen: Binding<Bool>) -> CustomTextField {
        var textField = self
        textField.keyboardOnScreen = keyboardOnScreen
        return textField
    }
    
    /// Set completion handler
    public func onCompletion(_ handler: @escaping () -> Void) -> CustomTextField {
        var textField = self
        textField.completionHandler = handler
        return textField
    }
    
    /// Set error messages
    public func errorMessages(_ errorMessages: Binding<ErrorMessages?>) -> CustomTextField {
        var textField = self
        textField.errorMessages = errorMessages
        return textField
    }
}

/// Secure Field with custom Design
struct CustomSecureField: View {
    
    /// Placeholder
    private var placeholder: String = "Placeholder"
    
    /// Binding of input text
    private var text: Binding<String> = .constant("")
    
    /// Binding containing if keyboard is on screen
    private var keyboardOnScreen: Binding<Bool>? = nil
    
    /// Error message type
    private var errorMessages: Binding<ErrorMessages?> = .constant(nil)
    
    /// Handler execuded after keyboard dismisses
    private var completionHandler: (() -> Void)? = nil
    
    /// Textfield size
    private var textFieldSize: (width: CGFloat?, height: CGFloat?)
    
    // Deprecated init with text, placeholder, keyboardOnScreen and completionHandler
    @available(*, deprecated, message: "replaced by init() and view modifiers")
    init(text: Binding<String>, placeholder: String, keyboardOnScreen: Binding<Bool> = .constant(false), completionHandler: (() -> ())? = nil) {
        self.placeholder = placeholder
        self.text = text
        self.keyboardOnScreen = keyboardOnScreen
        self.completionHandler = completionHandler
    }
    
    /// Init with default values
    public init() {}
    
    public var body: some View {
        VStack(spacing: 5) {
            ZStack {
                
                // Outline
                Outline()
                    .strokeColor(errorMessages.wrappedValue.map { _ in Color.custom.red })
                    .lineWidth(errorMessages.wrappedValue.map { _ in CGFloat(2) })
                
                // Text Field
                UISecureField(placeholder: placeholder, text: text, keyboardOnScreen: keyboardOnScreen ?? .constant(false), completionHandler: completionHandler)
                    .foregroundColor(.textColor)
                    .font(.text(20))
                    .lineLimit(1)
                    .padding(.horizontal, 10)
                    .multilineTextAlignment(.center)
            }.frame(width: textFieldSize.width, height: textFieldSize.height)
            
            // Error message
            ErrorMessageView(errorMessages: errorMessages)
        }.animation(.default)
    }
    
    /// Set textfield size
    public func textFieldSize(width: CGFloat? = nil, height: CGFloat? = nil) -> CustomSecureField {
        var textfield = self
        textfield.textFieldSize = (width: width, height: height)
        return textfield
    }
    
    /// Set textfield size
    public func textFieldSize(size: CGSize) -> CustomSecureField {
        var textfield = self
        textfield.textFieldSize = (width: size.width, height: size.height)
        return textfield
    }
    
    /// Set title
    public func title(_ title: String) -> CustomSecureField {
        var textField = self
        textField.placeholder = title
        return textField
    }
    
    /// Set text binding
    public func textBinding(_ text: Binding<String>) -> CustomSecureField {
        var textField = self
        textField.text = text
        return textField
    }
    
    /// Deprecated set keyboard on screen binding
    @available(*, deprecated, message: "use keyboardAdaptive view modifier instead")
    public func keyboardOnScreen(_ keyboardOnScreen: Binding<Bool>) -> CustomSecureField {
        var textField = self
        textField.keyboardOnScreen = keyboardOnScreen
        return textField
    }
    
    /// Set completion handler
    public func onCompletion(_ handler: @escaping () -> Void) -> CustomSecureField {
        var textField = self
        textField.completionHandler = handler
        return textField
    }
    
    /// Set error messages
    public func errorMessages(_ errorMessages: Binding<ErrorMessages?>) -> CustomSecureField {
        var textField = self
        textField.errorMessages = errorMessages
        return textField
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
