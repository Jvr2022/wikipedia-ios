class TextFormattingToolbarView: UIView, TextFormattingButtonsProviding {
    weak var delegate: TextFormattingDelegate?

    @IBOutlet var buttons: [TextFormattingButton] = []
}

extension TextFormattingToolbarView: Themeable {
    func apply(theme: Theme) {
        backgroundColor = theme.colors.paperBackground
        for button in buttons {
            button.apply(theme: theme)
        }
    }
}
