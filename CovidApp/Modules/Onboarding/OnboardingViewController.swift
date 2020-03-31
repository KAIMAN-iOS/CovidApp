//
//  OnboardingViewController.swift
//  CovidApp
//
//  Created by jerome on 28/03/2020.
//  Copyright © 2020 Jerome TONNELIER. All rights reserved.
//

import UIKit
import PaperOnboarding

protocol CloseDelegate: class {
    func close(_ controller: UIViewController)
}

class OnboardingViewController: UIViewController {

    @IBOutlet weak var quitButton: Button!
    weak var delegate: CloseDelegate? = nil

    static func create() -> OnboardingViewController {
        return OnboardingViewController.loadFromStoryboard(identifier: "OnboardingViewController", storyboardName: "Main")
    }

    @IBOutlet weak var paperView: PaperOnboarding!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadPapers()
        quitButton.setTitle("Onboarding letsGo title".local(), for: .normal)
        quitButton.configure(with: .inverted)
        // Do any additional setup after loading the view.
    }
    
    private var items: [OnboardingItemInfo] = []
    private func loadPapers() {
        items = Onboarding.allCases.compactMap({ onboarding in
            return OnboardingItemInfo(informationImage: onboarding.image,
                                          title: onboarding.title,
                                          description: onboarding.subtitle,
                                          pageIcon: onboarding.image!,
                                          color: Palette.basic.primary.color,
                                          titleColor: .white,
                                          descriptionColor: .white,
                                          titleFont: FontType.title.font,
                                          descriptionFont: FontType.default.font)
            
        })
        paperView.dataSource = self
        paperView.delegate = self
    }
    
    @IBAction func quit(_ sender: Any) {
        delegate?.close(self)
    }
}

extension OnboardingViewController: PaperOnboardingDataSource {
    func onboardingItem(at index: Int) -> OnboardingItemInfo {
        return items[index]
    }
    
    func onboardingItemsCount() -> Int {
        return items.count
    }
}

extension OnboardingViewController: PaperOnboardingDelegate {
    func onboardingWillTransitonToIndex(_ index: Int) {
        quitButton.isHidden = index == items.count  - 1 ? false : true
        view.bringSubviewToFront(quitButton)
    }
    
    var enableTapsOnPageControl: Bool {
        return false
    }
}
