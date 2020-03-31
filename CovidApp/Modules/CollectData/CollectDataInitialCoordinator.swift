//
//  CollectDataInitialCoordinator.swift
//  CovidApp
//
//  Created by jerome on 30/03/2020.
//  Copyright © 2020 Jerome TONNELIER. All rights reserved.
//

import UIKit
 // CollectDataInitialCoordinator

protocol InitialCollectDelegate: class {
    func pushNextController(for metric: GovernmentMetrics, answer: Validation)
}

protocol CollectDataInitialCoordinatorDelegate: class {
    func didFinishCollect(data: Answers)
}

//MARK: - AppCoordinator
class CollectDataInitialCoordinator: Coordinator<DeepLink> {
    
    var currentDataIndex = -1
    weak var closeDelegate: CloseDelegate? = nil
    weak var coordinatorDelegate: CollectDataInitialCoordinatorDelegate? = nil
    private var answers: Answers = Answers()
    
    init() {
        let router: Router = Router(navigationController: CollectInitialDataViewController.createRootController())
        super.init(router: router)
    }
    
    override func start() {
        pushNextController()
    }
    
    func pushNextController() {
        currentDataIndex += 1
        let currentController = CollectInitialDataViewController.create()
        currentController.closeDelegate = closeDelegate
        currentController.collectDataDelegate = self
        currentController.configure(with: GovernmentMetrics.allCases[currentDataIndex], index: currentDataIndex)
        currentController.isModalInPopover = true
        router.navigationController.presentationController?.delegate = currentController
        
        if currentDataIndex == 0 {
            router.setRootModule(currentController, hideBar: false, animated: false)
        } else {
            router.push(currentController, animated: true) {}
        }
    }
}

extension CollectDataInitialCoordinator: InitialCollectDelegate {
    func pushNextController(for metric: GovernmentMetrics, answer: Validation) {
        answers.append(metric: metric, for: answer)
        guard (GovernmentMetrics.allCases.firstIndex(of: metric) ?? 0) < GovernmentMetrics.allCases.count - 1 else {
            coordinatorDelegate?.didFinishCollect(data: answers)
            return
        }
        pushNextController()
    }
}
