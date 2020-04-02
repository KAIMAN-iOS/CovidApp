//
//  CollectDataInitialCoordinator.swift
//  CovidApp
//
//  Created by jerome on 30/03/2020.
//  Copyright © 2020 Jerome TONNELIER. All rights reserved.
//

import UIKit
 import SwiftyUserDefaults

protocol InitialCollectDelegate: class {
    func pushNextController(for metric: GovernmentMetrics, answer: Validation)
}

protocol CollectDataInitialCoordinatorDelegate: class {
    func didFinishCollect(data: Answers)
}

//MARK: - AppCoordinator
class CollectDataInitialCoordinator: Coordinator<DeepLink> {
    
    enum DataType {
        case metrics
        case initial
    }
    var collectType: DataType = .initial
    var currentDataIndex = -1
    weak var collectDelegate: CollectDailyMetricsDelegate? = nil
    weak var closeDelegate: CloseDelegate? = nil
    weak var coordinatorDelegate: CollectDataInitialCoordinatorDelegate? = nil
    private var answers: Answers = Answers()  {
        didSet {
            try? DataStorage().save(answers)
        }
    }

    init(collectType: DataType) {
        self.collectType = collectType
        switch collectType {
        case .initial:
            let router: Router = Router(navigationController: CollectInitialDataViewController.createRootController())
            super.init(router: router)
            
        case .metrics:
            let router: Router = Router(navigationController: UINavigationController())
            super.init(router: router)
        }
    }
    
    override func start() {
         switch collectType {
         case .initial:
            Defaults[\.initialValuesFilled] = true
            pushNextController()
            
         case .metrics:
            router.setRootModule(dailyMetricsController, hideBar: true, animated: false)
            dailyMetricsController.closeDelegate = closeDelegate
            dailyMetricsController.collectDelegate = collectDelegate
        }
    }
    
    let dailyMetricsController: CollectDataViewController = CollectDataViewController.create()
    
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
