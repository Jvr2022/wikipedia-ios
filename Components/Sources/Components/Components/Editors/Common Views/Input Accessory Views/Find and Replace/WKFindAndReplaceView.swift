import UIKit

protocol WKFindAndReplaceViewDelegate: AnyObject {
    func findAndReplaceView(_ view: WKFindAndReplaceView, didChangeFindText text: String)
    func findAndReplaceViewDidTapNext(_ view: WKFindAndReplaceView)
    func findAndReplaceViewDidTapPrevious(_ view: WKFindAndReplaceView)
}

class WKFindAndReplaceView: WKComponentView {
    
    // MARK: - IBOutlet Properties

    @IBOutlet private weak var outerContainer: UIView!
    @IBOutlet private var outerStackViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private var outerStackViewTrailingConstraint: NSLayoutConstraint!
    
    // Find outlets
    @IBOutlet private var findStackView: UIStackView!
    @IBOutlet private var nextPrevButtonStackView: UIStackView!
    @IBOutlet private(set) var findTextField: UITextField!
    @IBOutlet private var currentMatchInfoLabel: UILabel!
    @IBOutlet private var findClearButton: UIButton!
    @IBOutlet private var closeButton: UIButton!
    @IBOutlet private var nextButton: UIButton!
    @IBOutlet private var previousButton: UIButton!
    @IBOutlet private var magnifyImageView: UIImageView!
    @IBOutlet weak var findTextfieldContainer: UIView!
    
    // Replace outlets
    @IBOutlet private var replaceStackView: UIStackView!
    @IBOutlet private var replaceTextField: UITextField!
    @IBOutlet private var replaceTypeLabel: UILabel!
    @IBOutlet private var replacePlaceholderLabel: UILabel!
    @IBOutlet private var replaceClearButton: UIButton!
    @IBOutlet private var replaceButton: UIButton!
    @IBOutlet private var replaceSwitchButton: UIButton!
    @IBOutlet private var pencilImageView: UIImageView!
    @IBOutlet private weak var replaceTextfieldContainer: UIView!
    
    weak var delegate: WKFindAndReplaceViewDelegate?
    var viewModel: WKFindAndReplaceViewModel?
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()

        closeButton.setImage(WKSFSymbolIcon.for(symbol: .close), for: .normal)
        closeButton.accessibilityLabel = WKSourceEditorLocalizedStrings.current.accessibilityLabelFindButtonClose
        previousButton.setImage(WKSFSymbolIcon.for(symbol: .chevronUp), for: .normal)
        previousButton.accessibilityLabel = WKSourceEditorLocalizedStrings.current.accessibilityLabelFindButtonPrevious
        nextButton.setImage(WKSFSymbolIcon.for(symbol: .chevronDown), for: .normal)
        nextButton.accessibilityLabel = WKSourceEditorLocalizedStrings.current.accessibilityLabelFindButtonNext

        replaceButton.setImage(WKIcon.replace, for: .normal)
        replaceButton.accessibilityLabel = String.localizedStringWithFormat(WKSourceEditorLocalizedStrings.current.accessibilityLabelReplaceButtonPerformFormat, WKSourceEditorLocalizedStrings.current.accessibilityLabelReplaceTypeSingle)
        replaceSwitchButton.setImage(WKSFSymbolIcon.for(symbol: .ellipsis), for: .normal)
        replaceSwitchButton.accessibilityLabel = String.localizedStringWithFormat(WKSourceEditorLocalizedStrings.current.accessibilityLabelReplaceButtonSwitchFormat, WKSourceEditorLocalizedStrings.current.accessibilityLabelReplaceTypeSingle)

        magnifyImageView.image = WKSFSymbolIcon.for(symbol: .magnifyingGlass)
        pencilImageView.image = WKSFSymbolIcon.for(symbol: .pencil)
        
        findClearButton.setImage(WKSFSymbolIcon.for(symbol: .multiplyCircleFill), for: .normal)
        findClearButton.accessibilityLabel = WKSourceEditorLocalizedStrings.current.accessibilityLabelFindButtonClear
        replaceClearButton.setImage(WKSFSymbolIcon.for(symbol: .multiplyCircleFill), for: .normal)
        replaceClearButton.accessibilityLabel = WKSourceEditorLocalizedStrings.current.accessibilityLabelReplaceButtonClear

        findTextField.adjustsFontForContentSizeCategory = true
        findTextField.font = WKFont.for(.caption1, compatibleWith: appEnvironment.traitCollection)
        findTextField.accessibilityLabel = WKSourceEditorLocalizedStrings.current.accessibilityLabelFindTextField
        findTextField.autocorrectionType = .yes
        findTextField.spellCheckingType = .yes

        replaceTextField.adjustsFontForContentSizeCategory = true
        replaceTextField.font = WKFont.for(.caption1, compatibleWith: appEnvironment.traitCollection)
        replaceTextField.accessibilityLabel = WKSourceEditorLocalizedStrings.current.accessibilityLabelReplaceTextField
        replaceTextField.autocorrectionType = .yes
        replaceTextField.spellCheckingType = .yes
        
        replaceTypeLabel.text = WKSourceEditorLocalizedStrings.current.findReplaceTypeSingle
        replaceTypeLabel.isAccessibilityElement = false

        currentMatchInfoLabel.adjustsFontForContentSizeCategory = true
        currentMatchInfoLabel.font = WKFont.for(.caption1, compatibleWith: appEnvironment.traitCollection)

        replaceTypeLabel.adjustsFontForContentSizeCategory = true
        replaceTypeLabel.font = WKFont.for(.caption1, compatibleWith: appEnvironment.traitCollection)
        replaceTypeLabel.text = "Replace" // TODO

        replacePlaceholderLabel.adjustsFontForContentSizeCategory = true
        replacePlaceholderLabel.font = WKFont.for(.caption1, compatibleWith: appEnvironment.traitCollection)
        replacePlaceholderLabel.text = WKSourceEditorLocalizedStrings.current.findReplaceWith
        replacePlaceholderLabel.isAccessibilityElement = false

        updateColors()
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: 46)
    }
    
    // MARK: - Internal
    
    func update(viewModel: WKFindAndReplaceViewModel) {
        self.viewModel = viewModel
        
        updateConfiguration(configuration: viewModel.configuration)
        
        let findIsEmpty = (findTextField.text ?? "").isEmpty
        if let currentMatchInfo = viewModel.currentMatchInfo,
           !findIsEmpty {
            currentMatchInfoLabel.text = "\(currentMatchInfo)"
        } else {
            currentMatchInfoLabel.text = nil
        }
        
        nextButton.isEnabled = viewModel.nextPrevButtonsAreEnabled
        previousButton.isEnabled = viewModel.nextPrevButtonsAreEnabled
    }
    
    // MARK: - Overrides
    
    override func appEnvironmentDidChange() {
        
        // Confirm IBOutlets are populated first
        guard findTextField != nil else {
            return
        }
        
        updateColors()
    }

    // MARK: Public

      func focus() {
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
              self.findTextField.becomeFirstResponder()
          }
      }

    // MARK: - Button Actions
    
    @IBAction private func tappedFindClear() {
        findTextField.text = ""
        debouncedFindTextfieldDidChange()
    }
    
    @IBAction private func tappedReplaceClear() {
    }
    
    @IBAction private func tappedClose() {
    }
    
    @IBAction private func tappedNext() {
        delegate?.findAndReplaceViewDidTapNext(self)
    }
    
    @IBAction private func tappedPrevious() {
        delegate?.findAndReplaceViewDidTapPrevious(self)
    }
    
    @IBAction private func tappedReplace() {
    }
    
    @IBAction private func tappedReplaceSwitch() {
    }
    
    @IBAction private func textFieldDidChange(_ sender: UITextField) {
        if sender == self.findTextField {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(debouncedFindTextfieldDidChange), object: nil)
            perform(#selector(debouncedFindTextfieldDidChange), with: nil, afterDelay: 0.5)
        }
    }
    
    // MARK: - Private Helpers
    
    private func updateConfiguration(configuration: WKFindAndReplaceViewModel.Configuration) {
        switch configuration {
        case .findOnly:
            replaceStackView.isHidden = true
            closeButton.isHidden = false
            findStackView.insertArrangedSubview(nextPrevButtonStackView, at: 0)
            outerStackViewLeadingConstraint.constant = 10
            outerStackViewTrailingConstraint.constant = 5
            accessibilityElements = [previousButton, nextButton, findTextField, currentMatchInfoLabel, findClearButton, closeButton].compactMap { $0 as Any }
        case .findAndReplace:
            replaceStackView.isHidden = false
            closeButton.isHidden = true
            findStackView.addArrangedSubview(nextPrevButtonStackView)
            outerStackViewLeadingConstraint.constant = 18
            outerStackViewTrailingConstraint.constant = 18
            accessibilityElements = [findTextField, currentMatchInfoLabel, findClearButton, previousButton, nextButton, replaceTextField, replaceClearButton, replaceButton, replaceSwitchButton].compactMap { $0 as Any }
        }
    }
    
    private func updateColors() {
        let theme = WKAppEnvironment.current.theme
        
        backgroundColor = UIColor.systemGray4
        
        findTextField.keyboardAppearance = theme.keyboardAppearance
        findTextfieldContainer.backgroundColor = theme.keyboardBarSearchFieldBackground
        findTextField.textColor = theme.text
        closeButton.tintColor = theme.inputAccessoryButtonTint
        previousButton.tintColor = theme.inputAccessoryButtonTint
        nextButton.tintColor = theme.inputAccessoryButtonTint
        magnifyImageView.tintColor = theme.inputAccessoryButtonTint
        findClearButton.tintColor = theme.inputAccessoryButtonTint
        currentMatchInfoLabel.textColor = theme.secondaryText
        
        replaceTextField.keyboardAppearance = theme.keyboardAppearance
        replaceTextfieldContainer.backgroundColor = theme.keyboardBarSearchFieldBackground
        replaceTextField.textColor = theme.text
        replaceButton.tintColor = theme.inputAccessoryButtonTint
        replaceSwitchButton.tintColor = theme.inputAccessoryButtonTint
        pencilImageView.tintColor = theme.inputAccessoryButtonTint
        replaceClearButton.tintColor = theme.inputAccessoryButtonTint
        replaceTypeLabel.textColor = theme.secondaryText
        replacePlaceholderLabel.textColor = theme.secondaryText
    }
    
    @objc private func debouncedFindTextfieldDidChange() {

        guard let text = findTextField.text else {
            return
        }

        // TODO: also call from keyboard search button
        delegate?.findAndReplaceView(self, didChangeFindText: text)
    }
}
