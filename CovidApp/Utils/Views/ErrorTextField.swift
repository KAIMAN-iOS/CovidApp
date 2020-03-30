//
//  ErrorTextField.swift
//  Moovizy
//
//  Created by jerome on 10/04/2018.
//  Copyright © 2018 CITYWAY. All rights reserved.
//

import UIKit
import SnapKit
import SwiftDate

protocol ErrorTextFieldDelegate: class {
    func errorTextFieldNeedsLayout(_ textField: ErrorTextField)
}

struct Validator {
    static func isEmailValid(email: String?, includeEmpty: Bool = true) -> PopupErrorType? {
        if email?.isValidEmail ?? false {
            return nil
        } else if (email?.count ?? 0) == 0 && includeEmpty == false {
            return nil
        }
        return .emailIsInvalid
    }
}

enum TextFieldComponent {
    case email
    case lastName
    case firstName
    case birthDate
//    case zipCode
    
    var configuration: ErrorTextFieldConfiguration {
        switch self {
        case .email: return EmailTextFieldConfiguration()
        case .lastName: return LastNameTextFieldConfiguration()
        case .firstName: return FirstNameTextFieldConfiguration()
        case .birthDate: return BirthDateTextFieldConfiguration()
        }
    }
}

enum PopupErrorType {
    case emailIsInvalid
    case emailIsEmpty
    case fieldMandatory
    
    var errorText: String  {
        switch self {
        case .emailIsInvalid: return "The email address entered is not valid".local()
        case .emailIsEmpty: return "Email cannot be empty".local()
        case .fieldMandatory: return "Field mandatory".local()
        }
    }
}


// Default configuration for Moovizy
class ErrorTextFieldConfiguration {
    var title: String
    var entryInstruction: String?
    var keyboardType: UIKeyboardType
    var autocapitalizationType: UITextAutocapitalizationType
    var isSecure: Bool
    var showErrors: Bool
    var showPrediction: Bool
    var isMandatory: Bool
    var validator: ((_ text: String?, _ includeEmpty: Bool) -> (PopupErrorType?))?
    var maximumLength: Int?
    var hasDatePicker: Bool
    var datePickerMinimumDate: Date?
    var datePickerMaximumDate: Date?
    var datePickerDefaultDate: Date
    var dateFormat: String
    var hasShowPasswordButton: Bool = false
    
    init() {
        self.title = ""
        self.entryInstruction = nil
        self.keyboardType = .default
        self.isSecure = false
        showErrors = false
        self.showPrediction = false
        self.isMandatory = true
        self.hasDatePicker = false
        self.datePickerDefaultDate = Date()
        self.autocapitalizationType = .sentences
        self.dateFormat = "birthdate format".local()
        self.validator = { [weak self] in
            guard let self = self else {
                return nil
            }
            if self.isMandatory && $0?.count == 0 && $1 {
                return PopupErrorType.fieldMandatory
            }
            return nil
        }
    }
}

// Specific configuration
class EmailTextFieldConfiguration: ErrorTextFieldConfiguration {
    override init() {
        super.init()
        self.keyboardType = .emailAddress
        self.autocapitalizationType = .none
        self.title = "Email address".local()
        self.validator = {
            return Validator.isEmailValid(email: $0?.trimmingCharacters(in: CharacterSet.whitespaces), includeEmpty: $1)
        }
    }
}

class LastNameTextFieldConfiguration: ErrorTextFieldConfiguration {
    override init() {
        super.init()
        self.title = "Last name".local()
    }
}

class FirstNameTextFieldConfiguration: ErrorTextFieldConfiguration {
    override init() {
        super.init()
        self.title = "First name".local()
    }
}

class AddressTextFieldConfiguration: ErrorTextFieldConfiguration {
    override init() {
        super.init()
        self.title = "Address".local()
    }
}

class BirthDateTextFieldConfiguration: ErrorTextFieldConfiguration {
    override init() {
        super.init()
        self.title = "Birthdate".local()
//        self.entryInstruction = "(dd/mm/yyyy)".local()
        
        self.hasDatePicker = true
        self.datePickerMinimumDate = Date().addingTimeInterval(-120.0*365.25*24*3600)
        self.datePickerMaximumDate = Date()
        self.datePickerDefaultDate = Date().addingTimeInterval(-18.0*365.25*24*3600)
    }
}

class ErrorTextField: UIView {
    
    var type: TextFieldComponent?  {
        didSet {
            guard let compo = type else { return }
            configuration = compo.configuration
        }
    }

    // UI Components
    lazy var textField: UITextField = {
        var tf: UITextField!
        tf = UITextField.autolayout()
        tf.font = FontType.default.font
        tf.textColor = Palette.basic.mainTexts.color
        tf.typeObserver = true
        tf.setContentHuggingPriority(.required, for: .vertical)
        return tf
    } ()
    
    lazy var separatorView: UIView = {
        $0.backgroundColor = Palette.basic.lightGray.color
        $0.snp.makeConstraints { $0.height.equalTo(1) }
        return $0
    } (UIView.autolayout())
    
    lazy var titleLabel: UILabel = {
        $0.typeObserver = true
        $0.numberOfLines = 0
        $0.setContentHuggingPriority(.required, for: .vertical)
        $0.setContentCompressionResistancePriority(.required, for: .vertical)
        return $0
    } (UILabel.autolayout())
    
    lazy var errorMessageLabel: UILabel = {
        $0.typeObserver = true
        $0.set(text: " ", for: FontType.title)
        $0.numberOfLines = 0
        $0.setContentCompressionResistancePriority(.init(1000), for: .vertical)
        return $0
    } (UILabel.autolayout())
    
    lazy var errorIcon: UIImageView = {
        $0.image = UIImage(named: "ic_event_general")
        $0.tintColor = Palette.basic.alert.color
        $0.contentMode = .scaleAspectFit
        $0.snp.makeConstraints { $0.width.equalTo(15) }
        return $0
    } (UIImageView.autolayout())
    
    lazy var verticalStackView: UIStackView = {
        $0.alignment = .fill
        $0.distribution = .fill
        $0.axis = .vertical
        $0.spacing = 5
        return $0
    } (UIStackView.autolayout())
    
    lazy var horizontalStackView: UIStackView = {
        $0.alignment = .top
        $0.distribution = .fillProportionally
        $0.axis = .horizontal
        $0.spacing = 5
        return $0
    } (UIStackView())
    
    // Delegate
    weak var delegate: ErrorTextFieldDelegate? = nil
    
    // First responder
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var isFirstResponder: Bool {
        return self.textField.isFirstResponder
    }
    
    override func becomeFirstResponder() -> Bool {
        return self.textField.becomeFirstResponder()
    }
    
    // Comparaison
    static func ==(lft: ErrorTextField, rgt: UITextField) -> Bool {
        return lft.textField === rgt
    }
    var shouldHideEntryInstructionWhenNotEditable = true
    
    // Configuration
    internal var configuration: ErrorTextFieldConfiguration = ErrorTextFieldConfiguration() {
        didSet {
            // fix for the secure keyboard issue
            if #available(iOS 12.0, *) {
                self.textField.textContentType = .oneTimeCode
            }
            self.textField.keyboardType = configuration.keyboardType
            self.textField.autocapitalizationType = configuration.autocapitalizationType
            self.textField.isSecureTextEntry = configuration.isSecure
            self.textField.autocapitalizationType = configuration.autocapitalizationType
            self.textField.autocorrectionType = configuration.showPrediction ? .yes : .no
            if self.configuration.hasDatePicker {
                let datePickerView = UIDatePicker()
                datePickerView.maximumDate = self.configuration.datePickerMaximumDate
                datePickerView.minimumDate = self.configuration.datePickerMinimumDate
                datePickerView.date = self.configuration.datePickerDefaultDate
                datePickerView.datePickerMode = .date
                textField.inputView = datePickerView
                datePickerView.addTarget(self, action: #selector(handleDatePicker(sender:)), for: .valueChanged)
            }
            self.textField.delegate = self
            self.textField.returnKeyType = .done
            self.updateTitle()
        }
    }
    
    @objc internal func switchTextfieldState() {
        textField.isSecureTextEntry.toggle()
        (textField.rightView as? UIButton)?.setImage(UIImage(named:  textField.isSecureTextEntry == false ? "ic_navigation_show_password" : "ic_navigation_hide_password")?.resizedImage(newSize: CGSize(width: 25, height: 25)), for: .normal)
    }
    
    // Used to set title as it was before after an error has been fixed
    private var titleLabelAttributedTextBeforeError: NSAttributedString?
    
    //MARK: - Initializers
    init(frame: CGRect, type: TextFieldComponent) {
        super.init(frame: frame)
        self.type = type
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    //MARK: - Setup
    private func setupProperties() {
        self.backgroundColor = .white
        self.isInError = false
        self.horizontalStackView.clipsToBounds = true
    }
    
    private func setupLayout() {
        // Horizontal stackView
        self.errorIcon.snp.makeConstraints { make in
            make.height.equalTo(15).priority(900)
        }
        self.horizontalStackView.addArrangedSubview(self.errorIcon)
        self.horizontalStackView.addArrangedSubview(self.errorMessageLabel)
        
        // Vertical stackView
        self.addSubview(self.verticalStackView)
        self.verticalStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
        }
        self.verticalStackView.addArrangedSubview(self.titleLabel)
        self.verticalStackView.addArrangedSubview(self.textField)
        self.verticalStackView.addArrangedSubview(self.separatorView)
        self.verticalStackView.addArrangedSubview(self.horizontalStackView)
        
        let tap = UITapGestureRecognizer.init(target: textField, action: #selector(becomeFirstResponder))
        addGestureRecognizer(tap)
    }
    
    private func setupRx() {
//        self.textField.rx.text.skip(1)
//            .subscribe(onNext: { [weak self] text in
//                guard let strongSelf = self else {
//                    return
//                }
//                
//                strongSelf.validateField(includeEmpty: false, showError: strongSelf.configuration.showErrors)
//            }).disposed(by: self.disposeBag)
    }
    
    private func setup() {
        self.setupProperties()
        self.setupLayout()
        self.setupRx()
    }
    
    // Update title
    private func updateTitle() {
        let title: String = self.configuration.title
        self.textField.isSecureTextEntry = self.configuration.isSecure
        
        if let entryInstruction = self.configuration.entryInstruction {
            let attributedTitle = title.asAttributedString(for: FontType.title)
            let attrString = NSMutableAttributedString(attributedString: attributedTitle)
            attrString.append(NSAttributedString(string: " "))
            attrString.append(entryInstruction.asAttributedString(for: FontType.subTitle, textColor: Palette.basic.secondaryTexts.color))
            self.titleLabel.attributedText = attrString
        } else {
            self.titleLabel.set(text: title, for: .title, textColor: Palette.basic.mainTexts.color, backgroundColor: .clear)
        }
    }
    
    // Manage error state
    private var isInError: Bool = false {
        didSet {
            self.horizontalStackView.isHidden = (self.isInError == false)
            self.errorMessageLabel.alpha = 0
            self.horizontalStackView.alpha = self.isInError == false ? 0 : 1
            self.separatorView.backgroundColor = self.isInError ? Palette.basic.alert.color : Palette.basic.lightGray.color
            self.titleLabel.set(text: self.titleLabel.attributedText?.string ?? "", for: FontType.title, textColor: self.isInError ? Palette.basic.alert.color : Palette.basic.mainTexts.color, backgroundColor: .clear)
            if isInError {
                UIView.animate(withDuration: 0.2) {
                    self.errorMessageLabel.alpha = 1
                }
            }
            invalidateIntrinsicContentSize()
        }
    }
    
    func removeErrorMessage() {
        errorMessageLabel.set(text: " ", for: FontType.title)
        guard isInError else {
            isInError = false // reset the stackViews and states....;
            return
        }
        isInError = false
        if let titleLabelAttributedTextBeforeError = titleLabelAttributedTextBeforeError {
            titleLabel.attributedText = titleLabelAttributedTextBeforeError
        }
    }
    
    func set(errorMessage: String) {
        errorMessageLabel.set(text: errorMessage, for: .footnote, textColor: Palette.basic.alert.color, backgroundColor: .clear)
        
        // to avoid launching the animation again
        if isInError == false {
            titleLabelAttributedTextBeforeError = titleLabel.attributedText
            isInError = true
        }
    }
    
    // Layout
    override var intrinsicContentSize: CGSize {
        get {
            setNeedsLayout()
            return CGSize(width: self.frame.width, height: verticalStackView.frame.height)
        }
    }
    
    // Manage date picker if included
    @objc func handleDatePicker(sender: UIDatePicker) {
        self.textField.text = DateFormatter.readableDateFormatter.string(from: sender.date)
    }
    
    @objc dynamic var isValid: Bool = false
    // Validation
    func validateField(includeEmpty: Bool = true, showError: Bool = true) {
        
        // Use the validator if it exist
        guard let validator = self.configuration.validator else {
            self.isValid = true
            return
        }
        
        defer {
            self.isValid = (validator(textField.text, true) == nil)
        }
        
        // Validate and manage error
        if let error = validator(textField.text, includeEmpty) {
            if showError {
                set(errorMessage: error.errorText)
            }
            return
        }
        
        // No error
        removeErrorMessage()
    }
}

//MARK: - UITextFieldDelegate methods
extension ErrorTextField: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.validateField(includeEmpty: false, showError: true)
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.validateField(includeEmpty: false, showError: true)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            endEditing(true)
        }
        return true
    }
}
