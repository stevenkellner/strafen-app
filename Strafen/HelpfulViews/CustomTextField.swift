//
//  CustomTextField.swift
//  Strafen
//
//  Created by Steven on 10.05.21.
//

import SwiftUI
import Introspect

/// Text Field with custom Design
struct CustomTextField<Formatter, InputProperties>: View where Formatter: TextFieldFormatter, InputProperties: InputPropertiesProtocol {
    
    /// Type of the textfield
    private let textField: InputProperties.TextFields
    
    /// Binding of the input properties
    private let inputProperties: Binding<InputProperties>
    
    /// Textfield formatter
    private let formatter: Formatter
    
    /// Placeholder of Text field
    private var placeholder: String = "Placeholder"
    
    /// Handler execuded after keyboard dismisses
    private var completionHandler: (() -> Void)? = nil
    
    /// Inidcates whether textfield is secure
    private var isSecure: Bool = false
    
    /// Keyboard type
    private var keyboardType: UIKeyboardType = .default
    
    /// Textfield size
    private var textFieldSize: (width: CGFloat?, height: CGFloat?)
    
    /// Init with textfield and formatter
    /// - Parameter textField: type of textfields
    /// - Parameter inputProperties: Binding of the input properties
    /// - Parameter formatter: text field formatter
    public init(_ textField: InputProperties.TextFields, inputProperties: Binding<InputProperties>, formatter: Formatter) {
        self.textField = textField
        self.inputProperties = inputProperties
        self.formatter = formatter
    }
    
    /// Used to format textfield text
    @State private var formattedText: String = ""
    
    /// Indicates whether the textfield is focused
    @State private var textfieldFocused = false
    
    // -MARK: body
    
    public var body: some View {
        VStack(spacing: 5) {
            SingleOutlinedContent {
                ZStack {
                    
                    // Placeholder
                    if formattedText.isEmpty && !textfieldFocused {
                        Text(placeholder)
                            .foregroundColor(.textColor)
                            .font(.system(size: 24, weight: .light))
                            .lineLimit(1)
                            .padding(.horizontal, 10)
                            .opacity(0.5)
                            .allowsHitTesting(false)
                    }
                    
                    // Textfield
                    CustomUITextField($formattedText, secure: isSecure, keyboardType: keyboardType) { newText in
                        let originalText = formatter.originalText(newText)
                        formattedText = formatter.formattedText(originalText)
                        inputProperties.wrappedValue[textField] = originalText
                    } onEditingChanged: { appears in
                        textfieldFocused = appears
                        if !appears {
                            _ = inputProperties.wrappedValue.validateTextField(textField)
                            completionHandler?()
                            if let nextTextField = inputProperties.wrappedValue.nextTextField(after: textField) {
                                inputProperties.wrappedValue.firstResponders.becomeFirstResponder(nextTextField)
                            }
                        }
                    }
                    
                }
            }.strokeColor(inputProperties.wrappedValue[error: textField].map { _ in .customRed })
                .lineWidth(inputProperties.wrappedValue[error: textField].map { _ in 2 })
                .frame(width: textFieldSize.width, height: textFieldSize.height)
                .introspectTextField { textField in
                    inputProperties.wrappedValue.firstResponders.append(self.textField) {
                        textField.becomeFirstResponder()
                    }
                }
            
            // Error message
            if let errorMessage = inputProperties.wrappedValue[error: textField] {
                Text(errorMessage.message)
                    .foregroundColor(.customRed)
                    .font(.system(size: 20, weight: .regular))
                    .lineLimit(1)
                    .padding(.horizontal, 10)
            }
        }
    }
    
    // -MARK: textfield modifier
    
    /// Set textfield size
    /// - Parameters:
    ///   - width: width of the fextfield
    ///   - height: height of the textfield
    /// - Returns: modified textfield
    public func textFieldSize(width: CGFloat? = nil, height: CGFloat? = nil) -> CustomTextField {
        var textfield = self
        textfield.textFieldSize = (width: width, height: height)
        return textfield
    }
    
    /// Set textfield size
    /// - Parameter size: textfield size
    /// - Returns: modified textfield
    public func textFieldSize(size: CGSize) -> CustomTextField {
        var textfield = self
        textfield.textFieldSize = (width: size.width, height: size.height)
        return textfield
    }
    
    /// Sets textfield size to UIScreen.main.bounds.width * 0.95 x 55
    public var defaultTextFieldSize: CustomTextField {
        textFieldSize(width: UIScreen.main.bounds.width * 0.95, height: 55)
    }
    
    /// Set placeholder
    /// - Parameter placeholder: placeholder
    /// - Returns: modified textfield
    public func placeholder(_ placeholder: String) -> CustomTextField {
        var textField = self
        textField.placeholder = placeholder
        return textField
    }
    
    /// Set keyboard type
    /// - Parameter keyboardType: keyboard type
    /// - Returns: modified textfield
    public func keyboardType(_ keyboardType: UIKeyboardType) -> CustomTextField {
        var textField = self
        textField.keyboardType = keyboardType
        return textField
    }
    
    /// Sets if textfield is secure
    /// - Parameter secure: inidcates whether textfield is secure
    /// - Returns: modified textfield
    public func secure(_ secure: Bool) -> CustomTextField {
        var textField = self
        textField.isSecure = secure
        return textField
    }
    
    /// Sets textfield to secure
    public var secure: CustomTextField {
        secure(true)
    }
    
    /// Set completion handler
    /// - Parameter handler: completion handler
    /// - Returns: modified textfield
    public func onCompletion(_ handler: @escaping () -> Void) -> CustomTextField {
        var textField = self
        textField.completionHandler = handler
        return textField
    }
    
    // -MARK: CustomUITextField

    /// A control that displays an editable text interface.
    struct CustomUITextField: UIViewRepresentable {
        
        class Coordinator: NSObject, UITextFieldDelegate {
            
            /// The text to display and edit
            @Binding private var text: String
            
            /// Handler performed when text is changed
            private let onTextChanged: ((String) -> Void)?
            
            /// The action to perform when the user begins editing text and after the user finishes editing text.
            /// The closure receives a Boolean value that indicates the editing status: true when the user begins editing, false when they finish
            private let onEditingChanged: ((Bool) -> Void)?
            
            /// Creates a text field with a text
            /// - Parameters:
            ///   - text: The text to display and edit.
            ///   - onTextChanged: handler performed when text is changed
            ///   - onEditingChanged: The action to perform when the user begins editing text and after the user finishes editing text.
            ///     The closure receives a Boolean value that indicates the editing status: true when the user begins editing, false when they finish.
            init(_ text: Binding<String>, onTextChanged: ((String) -> Void)?, onEditingChanged: ((Bool) -> Void)?) {
                self._text = text
                self.onTextChanged = onTextChanged
                self.onEditingChanged = onEditingChanged
            }
            
            func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
                text = textField.text ?? text
                onTextChanged?(text)
                return true
            }
            
            func textFieldShouldClear(_ textField: UITextField) -> Bool {
                text = ""
                onTextChanged?(text)
                return true
            }
            
            func textFieldShouldReturn(_ textField: UITextField) -> Bool {
                UIApplication.shared.dismissKeyboard()
                return true
            }
            
            func textFieldDidBeginEditing(_ textField: UITextField) {
                onEditingChanged?(true)
            }
            
            func textFieldDidEndEditing(_ textField: UITextField) {
                text = textField.text ?? text
                onTextChanged?(text)
                onEditingChanged?(false)
            }
        }
        
        /// The text to display and edit
        @Binding private var text: String
        
        /// Inidcates whether textfield is secure
        private let secure: Bool
        
        /// Handler performed when text is changed
        private let onTextChanged: ((String) -> Void)?
        
        /// The action to perform when the user begins editing text and after the user finishes editing text.
        /// The closure receives a Boolean value that indicates the editing status: true when the user begins editing, false when they finish
        private let onEditingChanged: ((Bool) -> Void)?
        
        /// UI textfield
        private let textField: UITextField
        
        /// Creates a text field with a text
        /// - Parameters:
        ///   - text: The text to display and edit
        ///   - secure: Inidcates whether textfield is secure
        ///   - keyboardType: Keyboard type
        ///   - onTextChanged: Handler performed when text is changed
        ///   - onEditingChanged: The action to perform when the user begins editing text and after the user finishes editing text.
        ///     The closure receives a Boolean value that indicates the editing status: true when the user begins editing, false when they finish.
        init(_ text: Binding<String>, secure: Bool = false, keyboardType: UIKeyboardType = .default, onTextChanged: ((String) -> Void)? = nil, onEditingChanged: ((Bool) -> Void)? = nil) {
            self._text = text
            self.secure = secure
            self.onTextChanged = onTextChanged
            self.onEditingChanged = onEditingChanged
            self.textField = UITextField()
            self.textField.autocapitalizationType = .none
            self.textField.isSecureTextEntry = secure
            self.textField.clearsOnBeginEditing = secure
            self.textField.textAlignment = .center
            self.textField.clearButtonMode = .whileEditing
            self.textField.font = .systemFont(ofSize: 24, weight: .light)
            self.textField.textColor = UIColor(.textColor)
            self.textField.keyboardType = keyboardType
        }
        
        func makeCoordinator() -> Coordinator {
            Coordinator($text, onTextChanged: onTextChanged, onEditingChanged: onEditingChanged)
        }
        
        func makeUIView(context: UIViewRepresentableContext<CustomUITextField>) -> UITextField {
            self.textField.delegate = context.coordinator
            return self.textField
        }
        
        func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<CustomUITextField>) {
            uiView.text = text
        }
    }
}

// -MARK: extensions for default init

extension CustomTextField where Formatter == DefaultTextFieldFormatter {

    /// Init with textfield
    /// - Parameter textField: type of textfields
    /// - Parameter inputProperties: Binding of the input properties
    init(_ textField: InputProperties.TextFields, inputProperties: Binding<InputProperties>) {
        self.textField = textField
        self.inputProperties = inputProperties
        self.formatter = DefaultTextFieldFormatter()
    }
}

extension CustomTextField where InputProperties == DefaultInputProperties {
    
    /// Init with formatter
    /// - Parameter formatter: text field formatter
    init(formatter: Formatter) {
        self.textField = .textField
        self.inputProperties = .constant(DefaultInputProperties())
        self.formatter = formatter
    }
}

extension CustomTextField where Formatter == DefaultTextFieldFormatter, InputProperties == DefaultInputProperties {
    
    /// Init with default properties
    init() {
        self.textField = .textField
        self.inputProperties = .constant(DefaultInputProperties())
        self.formatter = DefaultTextFieldFormatter()
    }
}
