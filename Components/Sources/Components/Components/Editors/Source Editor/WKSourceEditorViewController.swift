import Foundation
import UIKit

public protocol WKSourceEditorViewControllerDelegate: AnyObject {
    func sourceEditorViewControllerDidTapFind(sourceEditorViewController: WKSourceEditorViewController)
    func sourceEditorViewControllerDidRemoveFindInputAccessoryView(sourceEditorViewController: WKSourceEditorViewController)
}

// MARK: NSNotification Names

extension Notification.Name {
    static let WKSourceEditorSelectionState = Notification.Name("WKSourceEditorSelectionState")
}

extension Notification {
    static let WKSourceEditorSelectionState = Notification.Name.WKSourceEditorSelectionState
    static let WKSourceEditorSelectionStateKey = "WKSourceEditorSelectionStateKey"
}

public class WKSourceEditorViewController: WKComponentViewController {
    
    // MARK: Nested Types

    enum InputAccessoryViewType {
        case expanding
        case highlight
        case find
    }
    
    // MARK: - Properties
    
    private let viewModel: WKSourceEditorViewModel
    private weak var delegate: WKSourceEditorViewControllerDelegate?
    private let textFrameworkMediator: WKSourceEditorTextFrameworkMediator
    private var scrollingToMatchCount: Int? = nil
    
    var textView: UITextView {
        return textFrameworkMediator.textView
    }
    
    // Input Accessory Views
    
    private(set) lazy var expandingAccessoryView: WKEditorToolbarExpandingView = {
        let view = UINib(nibName: String(describing: WKEditorToolbarExpandingView.self), bundle: Bundle.module).instantiate(withOwner: nil).first as! WKEditorToolbarExpandingView
        view.delegate = self
        view.accessibilityIdentifier = WKSourceEditorAccessibilityIdentifiers.current?.expandingToolbar
        return view
    }()
    
    private lazy var highlightAccessoryView: WKEditorToolbarHighlightView = {
        let view = UINib(nibName: String(describing: WKEditorToolbarHighlightView.self), bundle: Bundle.module).instantiate(withOwner: nil).first as! WKEditorToolbarHighlightView
        view.delegate = self
        view.accessibilityIdentifier = WKSourceEditorAccessibilityIdentifiers.current?.highlightToolbar
        return view
    }()
    
    private lazy var findAccessoryView: WKFindAndReplaceView = {
        let view = UINib(nibName: String(describing: WKFindAndReplaceView.self), bundle: Bundle.module).instantiate(withOwner: nil).first as! WKFindAndReplaceView
        view.update(viewModel: WKFindAndReplaceViewModel())
        view.accessibilityIdentifier = WKSourceEditorAccessibilityIdentifiers.current?.findToolbar
        view.delegate = self
        return view
    }()
    
    // Input Views
    
    private lazy var editorInputView: UIView? = {
        let inputView = WKEditorInputView(delegate: self)
        inputView.accessibilityIdentifier = WKSourceEditorAccessibilityIdentifiers.current?.inputView
        return inputView
    }()
    
    // Input Tracking Properties
    
    var editorInputViewIsShowing: Bool? = false {
        didSet {
            
            guard editorInputViewIsShowing == true else {
                textView.inputView = nil
                textView.reloadInputViews()
                return
            }
            
            textView.inputView = editorInputView
            textView.inputAccessoryView = nil
            textView.reloadInputViews()
        }
    }
    var inputAccessoryViewType: InputAccessoryViewType? = nil {
        didSet {
            
            guard let inputAccessoryViewType else {
                textView.inputAccessoryView = nil
                textView.reloadInputViews()
                return
            }
            
            if oldValue == .find && inputAccessoryViewType != .find {
                delegate?.sourceEditorViewControllerDidRemoveFindInputAccessoryView(sourceEditorViewController: self)
            }
            
            switch inputAccessoryViewType {
            case .expanding:
                textView.inputAccessoryView = expandingAccessoryView
            case .highlight:
                textView.inputAccessoryView = highlightAccessoryView
            case .find:
                textView.inputAccessoryView = findAccessoryView
                findAccessoryView.focus()
            }
            
            textView.inputView = nil
            textView.reloadInputViews()
        }
    }
    
    // MARK: - Lifecycle
    
    public init(viewModel: WKSourceEditorViewModel, delegate: WKSourceEditorViewControllerDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
        self.textFrameworkMediator = WKSourceEditorTextFrameworkMediator(viewModel: viewModel)
        super.init()
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        textView.delegate = self
        textFrameworkMediator.delegate = self
        view.addSubview(textView)
        updateColorsAndFonts()
        
        NSLayoutConstraint.activate([
            view.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: textView.leadingAnchor),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: textView.trailingAnchor),
            view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: textView.topAnchor),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: textView.bottomAnchor)
        ])
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillChangeFrame(_:)),
                                               name: UIApplication.keyboardWillChangeFrameNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIApplication.keyboardWillHideNotification,
                                               object: nil)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setup(viewModel: viewModel)
        inputAccessoryViewType = .expanding
    }
    
    // MARK: Overrides
    
    public override func appEnvironmentDidChange() {
        updateColorsAndFonts()
    }
    
    // MARK: - Notifications
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        updateInsets(keyboardHeight: 0)
    }
    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let height = max(frame.height - view.safeAreaInsets.bottom, 0)
            updateInsets(keyboardHeight: height)
        }
    }
    
    // MARK: - Public
    
    public func closeFind() {
        if let selectedMatchRange = textFrameworkMediator.findAndReplaceFormatter?.selectedMatchRange, selectedMatchRange.location != NSNotFound {
            textView.selectedRange = selectedMatchRange
        } else if let lastReplacedRange = textFrameworkMediator.findAndReplaceFormatter?.lastReplacedRange,
                  lastReplacedRange.location != NSNotFound {
            textView.selectedRange = lastReplacedRange
        } else {
            // TODO: select a range on screen. Test by searching for a nonexisting string, then closing find.
        }
        textView.isEditable = true
        textView.becomeFirstResponder()
        inputAccessoryViewType = .expanding
        resetFind()
    }
    
    public func toggleSyntaxHighlighting() {
        viewModel.isSyntaxHighlightingEnabled.toggle()
        update(viewModel: viewModel)
    }
}

// MARK: - Private

private extension WKSourceEditorViewController {

    func setup(viewModel: WKSourceEditorViewModel) {
        textFrameworkMediator.isSyntaxHighlightingEnabled = viewModel.isSyntaxHighlightingEnabled
        textView.attributedText = NSAttributedString(string: viewModel.initialText)
    }
    
    func update(viewModel: WKSourceEditorViewModel) {
        textFrameworkMediator.isSyntaxHighlightingEnabled = viewModel.isSyntaxHighlightingEnabled
    }
    
    func updateInsets(keyboardHeight: CGFloat) {
        textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
        textView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0)
    }
    
    func updateColorsAndFonts() {
        view.backgroundColor = WKAppEnvironment.current.theme.paperBackground
        textView.backgroundColor = WKAppEnvironment.current.theme.paperBackground
        textView.keyboardAppearance = WKAppEnvironment.current.theme.keyboardAppearance
        textFrameworkMediator.updateColorsAndFonts()
    }
    
    func selectionState() -> WKSourceEditorSelectionState {
        return textFrameworkMediator.selectionState(selectedDocumentRange: textView.selectedRange)
    }
    
    func postUpdateButtonSelectionStatesNotification(withDelay delay: Bool) {
        let selectionState = selectionState()
        if delay {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                NotificationCenter.default.post(name: Notification.WKSourceEditorSelectionState, object: nil, userInfo: [Notification.WKSourceEditorSelectionStateKey: selectionState])
            }
        } else {
            NotificationCenter.default.post(name: Notification.WKSourceEditorSelectionState, object: nil, userInfo: [Notification.WKSourceEditorSelectionStateKey: selectionState])
        }
    }
    
    func resetFind() {
        guard var viewModel = findAccessoryView.viewModel else {
            return
        }
        // TODO: disable next / prev buttons
        viewModel.reset()
        findAccessoryView.update(viewModel: viewModel)
        textFrameworkMediator.findReset()
    }
    
    func updateFindCurrentMatchInfo() {
        
        guard var viewModel = findAccessoryView.viewModel,
              let findFormatter = textFrameworkMediator.findAndReplaceFormatter else {
            return
        }
        
        if findFormatter.selectedMatchIndex != NSNotFound {
            viewModel.currentMatchInfo = "\(findFormatter.selectedMatchIndex + 1) / \(findFormatter.matchCount)"
        } else if findFormatter.matchCount == 0 {
            viewModel.currentMatchInfo = "0 / 0"
        } else {
            viewModel.currentMatchInfo = nil
        }
        
        
        findAccessoryView.update(viewModel: viewModel)
    }
}

// MARK: - UITextViewDelegate

extension WKSourceEditorViewController: UITextViewDelegate {
    public func textViewDidChangeSelection(_ textView: UITextView) {
        guard editorInputViewIsShowing == false else {
            postUpdateButtonSelectionStatesNotification(withDelay: false)
            return
        }
        
        if inputAccessoryViewType == .find {
            return
        }
        
        let isRangeSelected = textView.selectedRange.length > 0
        inputAccessoryViewType = isRangeSelected ? .highlight : .expanding
        postUpdateButtonSelectionStatesNotification(withDelay: false)
    }
}

// MARK: - WKEditorToolbarExpandingViewDelegate

extension WKSourceEditorViewController: WKEditorToolbarExpandingViewDelegate {
    
    func toolbarExpandingViewDidTapFind(toolbarView: WKEditorToolbarExpandingView) {
        inputAccessoryViewType = .find
        delegate?.sourceEditorViewControllerDidTapFind(sourceEditorViewController: self)
        textView.isEditable = false
    }
    
    func toolbarExpandingViewDidTapFormatText(toolbarView: WKEditorToolbarExpandingView) {
        editorInputViewIsShowing = true
        postUpdateButtonSelectionStatesNotification(withDelay: true)
    }
    
    func toolbarExpandingViewDidTapTemplate(toolbarView: WKEditorToolbarExpandingView, isSelected: Bool) {
        let action: WKSourceEditorFormatterButtonAction = isSelected ? .remove : .add
        textFrameworkMediator.templateFormatter?.toggleTemplateFormatting(action: action, in: textView)
    }
    
    func toolbarExpandingViewDidTapUnorderedList(toolbarView: WKEditorToolbarExpandingView, isSelected: Bool) {
        let action: WKSourceEditorFormatterButtonAction = isSelected ? .remove : .add
        textFrameworkMediator.listFormatter?.toggleListBullet(action: action, in: textView)
    }
    
    func toolbarExpandingViewDidTapOrderedList(toolbarView: WKEditorToolbarExpandingView, isSelected: Bool) {
        let action: WKSourceEditorFormatterButtonAction = isSelected ? .remove : .add
        textFrameworkMediator.listFormatter?.toggleListNumber(action: action, in: textView)
    }
    
    func toolbarExpandingViewDidTapIncreaseIndent(toolbarView: WKEditorToolbarExpandingView) {
        textFrameworkMediator.listFormatter?.tappedIncreaseIndent(currentSelectionState: selectionState(), textView: textView)
    }
    
    func toolbarExpandingViewDidTapDecreaseIndent(toolbarView: WKEditorToolbarExpandingView) {
        textFrameworkMediator.listFormatter?.tappedDecreaseIndent(currentSelectionState: selectionState(), textView: textView)
    }
}

// MARK: - WKEditorToolbarHighlightViewDelegate

extension WKSourceEditorViewController: WKEditorToolbarHighlightViewDelegate {
    
    func toolbarHighlightViewDidTapBold(toolbarView: WKEditorToolbarHighlightView, isSelected: Bool) {
        let action: WKSourceEditorFormatterButtonAction = isSelected ? .remove : .add
        textFrameworkMediator.boldItalicsFormatter?.toggleBoldFormatting(action: action, in: textView)
    }
    
    func toolbarHighlightViewDidTapItalics(toolbarView: WKEditorToolbarHighlightView, isSelected: Bool) {
        let action: WKSourceEditorFormatterButtonAction = isSelected ? .remove : .add
        textFrameworkMediator.boldItalicsFormatter?.toggleItalicsFormatting(action: action, in: textView)
    }
    
    func toolbarHighlightViewDidTapTemplate(toolbarView: WKEditorToolbarHighlightView, isSelected: Bool) {
        let action: WKSourceEditorFormatterButtonAction = isSelected ? .remove : .add
        textFrameworkMediator.templateFormatter?.toggleTemplateFormatting(action: action, in: textView)
    }
    
    func toolbarHighlightViewDidTapShowMore(toolbarView: WKEditorToolbarHighlightView) {
        editorInputViewIsShowing = true
        postUpdateButtonSelectionStatesNotification(withDelay: true)
    }
}

// MARK: - WKEditorInputViewDelegate

extension WKSourceEditorViewController: WKEditorInputViewDelegate {
    func didTapHeading(type: WKEditorInputView.HeadingButtonType) {
        textFrameworkMediator.headingFormatter?.toggleHeadingFormatting(selectedHeading: type, currentSelectionState: selectionState(), textView: textView)
    }
    
    func didTapBold(isSelected: Bool) {
        let action: WKSourceEditorFormatterButtonAction = isSelected ? .remove : .add
        textFrameworkMediator.boldItalicsFormatter?.toggleBoldFormatting(action: action, in: textView)
    }
    
    func didTapItalics(isSelected: Bool) {
        let action: WKSourceEditorFormatterButtonAction = isSelected ? .remove : .add
        textFrameworkMediator.boldItalicsFormatter?.toggleItalicsFormatting(action: action, in: textView)
    }
    
    func didTapTemplate(isSelected: Bool) {
        let action: WKSourceEditorFormatterButtonAction = isSelected ? .remove : .add
        textFrameworkMediator.templateFormatter?.toggleTemplateFormatting(action: action, in: textView)
    }
    
    func didTapBulletList(isSelected: Bool) {
        let action: WKSourceEditorFormatterButtonAction = isSelected ? .remove : .add
        textFrameworkMediator.listFormatter?.toggleListBullet(action: action, in: textView)
    }
    
    func didTapNumberList(isSelected: Bool) {
        let action: WKSourceEditorFormatterButtonAction = isSelected ? .remove : .add
        textFrameworkMediator.listFormatter?.toggleListNumber(action: action, in: textView)
    }
    
    func didTapIncreaseIndent() {
        textFrameworkMediator.listFormatter?.tappedIncreaseIndent(currentSelectionState: selectionState(), textView: textView)
    }
    
    func didTapDecreaseIndent() {
        textFrameworkMediator.listFormatter?.tappedDecreaseIndent(currentSelectionState: selectionState(), textView: textView)
    }
    
    func didTapStrikethrough(isSelected: Bool) {
        let action: WKSourceEditorFormatterButtonAction = isSelected ? .remove : .add
        textFrameworkMediator.strikethroughFormatter?.toggleStrikethroughFormatting(action: action, in: textView)
    }
    
    func didTapClose() {
        editorInputViewIsShowing = false
        let isRangeSelected = textView.selectedRange.length > 0
        inputAccessoryViewType = isRangeSelected ? .highlight : .expanding
    }
}

// MARK: - WKFindAndReplaceViewDelegate

extension WKSourceEditorViewController: WKFindAndReplaceViewDelegate {
    func findAndReplaceView(_ view: WKFindAndReplaceView, didChangeFindText text: String) {
        resetFind()
        // TODO: show spinner on find
        textFrameworkMediator.findStart(text: text)
        updateFindCurrentMatchInfo()
        // TODO: end spinner on find
        // TODO: enable next / prev buttons
    }
    
    func findAndReplaceViewDidTapNext(_ view: WKFindAndReplaceView) {
        
        textFrameworkMediator.findNext(afterRange: nil)
        updateFindCurrentMatchInfo()
    }
    
    func findAndReplaceViewDidTapPrevious(_ view: WKFindAndReplaceView) {
        textFrameworkMediator.findPrevious()
        updateFindCurrentMatchInfo()
    }
    
    func findAndReplaceView(_ view: WKFindAndReplaceView, didTapReplaceSingle text: String) {
        // TODO: show spinner on find
        textFrameworkMediator.replaceSingle(text: text)
        updateFindCurrentMatchInfo()
        // TODO: end spinner on find
        // TODO: enable next / prev buttons
    }
    
    func findAndReplaceView(_ view: WKFindAndReplaceView, didTapReplaceAll text: String) {
        // TODO: show spinner on find
        textFrameworkMediator.replaceAll(text: text)
        updateFindCurrentMatchInfo()
        // TODO: end spinner on find
        // TODO: enable next / prev buttons
    }
}

// MARK: - WKSourceEditorFindAndReplaceScrollDelegate

extension WKSourceEditorViewController: WKSourceEditorFindAndReplaceScrollDelegate {
    
    func scrollToCurrentMatch() {
        guard let matchRange = textFrameworkMediator.findAndReplaceFormatter?.selectedMatchRange else {
            return
        }
        guard matchRange.location != NSNotFound else {
            return
        }
        
        if let scrollingToMatchCount {
            self.scrollingToMatchCount = scrollingToMatchCount + 1
        } else {
            self.scrollingToMatchCount = 1
        }
        
        if let startPos = textView.position(from: textView.beginningOfDocument, offset: matchRange.location),
           let endPos = textView.position(from: startPos, offset: matchRange.length),
           let textRange = textView.textRange(from: startPos, to: endPos) {
            let matchRect = textView.firstRect(for: textRange)
            
            textView.scrollRectToVisible(matchRect, animated: false)
            
            // Sometimes scrolling is off, try again.
            if let scrollingToMatchCount,
               scrollingToMatchCount < 2 {
                scrollToCurrentMatch()
            } else {
                scrollingToMatchCount = nil
                textView.flashScrollIndicators()
            }
        }
    }
}
