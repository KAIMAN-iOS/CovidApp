//
//  CollectInitialDataViewController.swift
//  CovidApp
//
//  Created by jerome on 30/03/2020.
//  Copyright © 2020 Jerome TONNELIER. All rights reserved.
//

import UIKit

class CollectInitialDataViewController: UIViewController {

    weak var collectDataDelegate: InitialCollectDelegate? = nil
    weak var closeDelegate: CloseDelegate? = nil
    static func create() -> CollectInitialDataViewController {
        return CollectInitialDataViewController.loadFromStoryboard(identifier: "CollectInitialDataViewController", storyboardName: "Main") 
    }
    
    static func createRootController() -> UINavigationController {
        return  UINavigationController.loadFromStoryboard(identifier: "CollectInitialDataNavigationController", storyboardName: "Main")
    }
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var questionNumberLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet var actionButtons: [ActionButton]!
    
    
    @IBAction func didSelect(_ sender: ActionButton) {
        var validation = item.validationButtons[actionButtons.firstIndex(of: sender) ?? 0]
        switch validation {
        case .continue where valueType != nil:
            validation = .value(valueType!.values[pickerView.selectedRow(inComponent: 0)])
        default: ()
        }
        collectDataDelegate?.pushNextController(for: item, answer: validation)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "reports".local()
        loadData()
    }
    
    private var valueType: GovernmentMetrics.ValueType?  {
        didSet {
            guard valueType != nil else {
                pickerView.isHidden = true
                return
            }
            pickerView.isHidden = false
            pickerView.selectRow(valueType!.defaultSelectedIndex, inComponent: 0, animated: false)
        }
    }

    private var item: GovernmentMetrics!
    private var currentMetricIndex: Int!
    func configure(with item: GovernmentMetrics, index: Int) {
        self.item = item
        currentMetricIndex = index
    }
    
    private func loadData() {
        valueType = item.inputValue
        textLabel.set(text: item.displayText, for: .title, textColor: Palette.basic.primary.color)
        questionNumberLabel.set(text: String(format: "report number format".local(), currentMetricIndex + 1, GovernmentMetrics.allCases.count), for: .default)
        actionButtons.forEach({ $0.isHidden = true })
        for (buttonIndex, validation) in item.validationButtons.enumerated() {
            actionButtons[buttonIndex].isHidden = false
            actionButtons[buttonIndex].actionButtonType = validation.actionButtonType
            actionButtons[buttonIndex].setTitle(validation.text, for: .normal)
        }
    }
    
    @IBAction func close(_ sender: Any) {
        confirmCancel()
    }
    
    func confirmCancel() {
        
        // Present an action sheet, which in a regular width environment appears as a popover
        
        let alert = UIAlertController(title: "close report title".local(), message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "close".local(), style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.closeDelegate?.close(self)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel".local(), style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension CollectInitialDataViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return valueType != nil ? valueType!.displayValues[row] : nil
    }
}

extension CollectInitialDataViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return valueType?.displayValues.count ?? 0
    }
}

extension CollectInitialDataViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        confirmCancel()
    }
}
