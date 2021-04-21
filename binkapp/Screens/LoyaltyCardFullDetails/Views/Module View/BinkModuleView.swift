import UIKit

protocol BinkModuleViewDelegate: class {
    func binkModuleViewWasTapped(moduleView: BinkModuleView, withState state: ModuleState)
}

class BinkModuleView: CustomView {
    @IBOutlet private weak var moduleImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var contentView: UIView!
    
    private var viewModel: BinkModuleViewModel!
    private weak var delegate: BinkModuleViewDelegate?
    
    func configure(with viewModel: BinkModuleViewModel, delegate: BinkModuleViewDelegate? = nil) {
        self.viewModel = viewModel
        self.delegate = delegate
        
        contentView.backgroundColor = Current.themeManager.color(for: .walletCardBackground)
        moduleImageView.image = UIImage(named: viewModel.imageName)
        titleLabel.text = viewModel.titleText
        titleLabel.textColor = Current.themeManager.color(for: .text)
        subtitleLabel.text = viewModel.subtitleText
        subtitleLabel.textColor = Current.themeManager.color(for: .text)
        
        layer.applyDefaultBinkShadow()
    }
    
    // MARK: - Actions
    
    @IBAction func pointsModuleTapped(_ sender: Any) {
        delegate?.binkModuleViewWasTapped(moduleView: self, withState: viewModel.state)
    }
}
