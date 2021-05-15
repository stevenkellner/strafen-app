//
//  CustomTextField.swift
//  Strafen
//
//  Created by Steven on 10.05.21.
//

import SwiftUI
import Introspect

/// Text Field with custom Design
struct CustomTextField<InputProperties>: View where InputProperties: InputPropertiesProtocol {
    
    /// Type of the textfield
    private let textField: InputProperties.TextFields
    
    /// Binding of the input properties
    private let inputProperties: Binding<InputProperties>
    
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
    
    /// Proxy of scroll view reader
    private var scrollViewProxy: ScrollViewProxy? = nil
    
    /// Indicates wheater error messge is shown
    private var showErrorMessage = true
    
    /// Init with textfield
    /// - Parameter textField: type of textfields
    /// - Parameter inputProperties: Binding of the input properties
    public init(_ textField: InputProperties.TextFields, inputProperties: Binding<InputProperties>) {
        self.textField = textField
        self.inputProperties = inputProperties
    }
    
    // -MARK: body
    
    public var body: some View {
        VStack(spacing: 5) {
            SingleOutlinedContent {
                    
                // Textfield
                UICustomTextField(text: inputProperties[textField])
                    .placeholder(placeholder)
                    .secure(isSecure)
                    .color(inputProperties.wrappedValue[error: textField].map { _ in .customRed } ?? .textColor)
                    .onCompletion {
                        _ = inputProperties.wrappedValue.validateTextField(textField)
                        completionHandler?()
                        if let nextTextField = inputProperties.wrappedValue.nextTextField(after: textField) {
                            inputProperties.wrappedValue.firstResponders.becomeFirstResponder(nextTextField)
                            scrollViewProxy?.scrollTo(nextTextField, anchor: UnitPoint(x: 0, y: 0.1))
                        }
                    }

            }.strokeColor(inputProperties.wrappedValue[error: textField].map { _ in .customRed })
                .lineWidth(inputProperties.wrappedValue[error: textField].map { _ in 2 })
                .frame(width: textFieldSize.width, height: textFieldSize.height)
                .id(textField)
                .introspectTextField { textField in
                    inputProperties.wrappedValue.firstResponders.append(self.textField) {
                        textField.becomeFirstResponder()
                    }
                }
            
            // Error message
            if showErrorMessage {
                ErrorMessageView(inputProperties[error: textField])
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
    
    /// Sets scroll view proxy
    /// - Parameter proxy: proxy of scroll view reader
    /// - Returns: modified textfield
    public func scrollViewProxy(_ proxy: ScrollViewProxy) -> CustomTextField {
        var textField = self
        textField.scrollViewProxy = proxy
        return textField
    }
    
    /// Set completion handler
    /// - Parameter handler: completion handler
    /// - Returns: modified textfield
    public func onCompletion(_ handler: @escaping () -> Void) -> CustomTextField {
        var textField = self
        textField.completionHandler = handler
        return textField
    }
    
    /// Sets show error message
    /// - Parameter show: indicates wheater error messge is shown
    /// - Returns: modified textfield
    public func showErrorMessage(_ show: Bool) -> CustomTextField {
        var textField = self
        textField.showErrorMessage = show
        return textField
    }
    
    /// Sets show error message to false
    public var hideErrorMessage: CustomTextField {
        showErrorMessage(false)
    }
    
    // -MARK: Custom UI Textfield
    
    /// Custom UI Textfield
    struct UICustomTextField: UIViewRepresentable {
        
        /// Input text
        @Binding var text: String
        
        /// Init with input text
        /// - Parameter text: input text
        init(text: Binding<String>) {
            self._text = text
        }
        
        /// Placeholder
        private var placeholder: String = "Placeholder"
        
        /// Inidcates whether textfield is secure
        private var isSecure: Bool = false
        
        /// Textfield color
        private var color: Color = .textColor
        
        /// Handler execuded after keyboard dismisses
        private var completionHandler: (() -> Void)? = nil
        
        /// UISecureField Coordinator
        class Coordinator: NSObject, UITextFieldDelegate {
            
            /// Input text
            @Binding var text: String
            
            /// Handler execuded after keyboard dismisses
            let completionHandler: (() -> Void)?
            
            /// Init with text and completion handler
            /// - Parameter text: input text
            /// - Parameter completionHandler: handler execuded after keyboard dismisses
            init(text: Binding<String>, handler completionHandler: (() -> Void)?) {
                self._text = text
                self.completionHandler = completionHandler
            }
            
            func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
                if let text = textField.text { self.text = text }
                return true
            }
            
            func textFieldShouldClear(_ textField: UITextField) -> Bool {
                text = ""
                return true
            }
            
            func textFieldShouldReturn(_ textField: UITextField) -> Bool {
                UIApplication.shared.dismissKeyboard()
                return true
            }
            
            
            func textFieldDidEndEditing(_ textField: UITextField) {
                if let text = textField.text { self.text = text }
                completionHandler?()
            }
        }
        
        func makeCoordinator() -> Coordinator {
            Coordinator(text: $text, handler: completionHandler)
        }
        
        func makeUIView(context: UIViewRepresentableContext<UICustomTextField>) -> UITextField {
            let textField = UITextField()
            textField.delegate = context.coordinator
            textField.autocapitalizationType = .none
            textField.isSecureTextEntry = isSecure
            textField.clearsOnBeginEditing = isSecure
            textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [.foregroundColor: UIColor(.textColor.opacity(0.5))])
            textField.textAlignment = .center
            textField.clearButtonMode = .whileEditing
            textField.font = .systemFont(ofSize: 20, weight: .regular)
            textField.textColor = UIColor(color)
            return textField
        }
        
        func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<UICustomTextField>) {
            uiView.text = text
        }
        
        /// Set placeholder
        /// - Parameter placeholder: placeholder
        /// - Returns: modified textfield
        public func placeholder(_ placeholder: String) -> UICustomTextField {
            var textField = self
            textField.placeholder = placeholder
            return textField
        }
        
        /// Sets text color
        /// - Parameter color: text color
        /// - Returns: modified textfield
        public func color(_ color: Color) -> UICustomTextField {
            var textField = self
            textField.color = color
            return textField
        }
        
        /// Sets if textfield is secure
        /// - Parameter secure: inidcates whether textfield is secure
        /// - Returns: modified textfield
        public func secure(_ secure: Bool) -> UICustomTextField {
            var textField = self
            textField.isSecure = secure
            return textField
        }
        
        /// Sets textfield to secure
        public var secure: UICustomTextField {
            secure(true)
        }
        
        /// Set completion handler
        /// - Parameter handler: completion handler
        /// - Returns: modified textfield
        public func onCompletion(_ handler: @escaping () -> Void) -> UICustomTextField {
            var textField = self
            textField.completionHandler = handler
            return textField
        }
    }
}

// -MARK: extensions for default init

extension CustomTextField where InputProperties == DefaultInputProperties {
    
    /// Init with default properties
    init() {
        self.textField = .textField
        self.inputProperties = .constant(DefaultInputProperties())
    }
}
