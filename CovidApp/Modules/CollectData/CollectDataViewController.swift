//
//  CollectDataViewController.swift
//  CovidApp
//
//  Created by jerome on 30/03/2020.
//  Copyright © 2020 Jerome TONNELIER. All rights reserved.
//

import UIKit
import Shuffle

class CollectDataViewController: UIViewController {

    weak var closeDelegate: CloseDelegate? = nil
    static func create() -> CollectDataViewController {
        return CollectDataViewController.loadFromStoryboard(identifier: "CollectDataViewController", storyboardName: "Main")
    }
    
    @IBOutlet weak var swipeCardStack: SwipeCardStack!
    @IBOutlet weak var noButton: ActionButton!  {
        didSet {
            noButton.actionButtonType = .swipeCardButton(isYesButton: false)
            noButton.setTitle("no".local().uppercased(), for: .normal)
        }
    }

    @IBOutlet weak var yesButton: ActionButton!  {
        didSet {
            yesButton.actionButtonType = .swipeCardButton(isYesButton: true)
            yesButton.setTitle("yes".local().uppercased(), for: .normal)
        }
    }

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var rewindButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        swipeCardStack.dataSource = self
        swipeCardStack.delegate = self
        // Do any additional setup after loading the view.
    }
    
    @IBAction func chooseNo(_ sender: Any) {
        swipeCardStack.swipe(.left, animated: true)
    }
    
    @IBAction func chooseYes(_ sender: Any) {
        swipeCardStack.swipe(.right, animated: true)
    }
    
    @IBAction func rewind(_ sender: Any) {
        swipeCardStack.undoLastSwipe(animated: true)
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

extension CollectDataViewController: SwipeCardStackDelegate {
    func cardStack(_ cardStack: SwipeCardStack, didSwipeCardAt index: Int, with direction: SwipeDirection) {
        
    }
}

extension CollectDataViewController: SwipeCardStackDataSource {
    func numberOfCards(in cardStack: SwipeCardStack) -> Int {
        return MetricType.allCases.count
    }
    
    func cardStack(_ cardStack: SwipeCardStack, cardForIndexAt index: Int) -> SwipeCard {
        return CovidSwipeCard(frame: swipeCardStack.bounds, metric: MetricType.allCases[index])
    }
}

extension CollectDataViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        confirmCancel()
    }
}

