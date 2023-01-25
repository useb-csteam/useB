//
//  ViewController.swift
//  @QuramMI
//


import UIKit


class ViewController: UIViewController {
    
    @IBOutlet var scanHolderName : UISwitch!
    
    fileprivate var tabIndex: Int = 0
    fileprivate var fcrvc: OcrViewController?

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        fcrvc = segue.destination as? OcrViewController
        tabIndex=self.tabBarController!.selectedIndex
        print("Selected tab!! \(tabIndex)")
        fcrvc?.setScannerType(tabIndex)
        //fcrvc?.setPrepareData(true, true, true, true)
        fcrvc?.setPrepareData(scanExpiry: true, validateNumber: true, validateExpiry: true, scanHolderName: scanHolderName.isOn)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

extension ViewController: UITabBarControllerDelegate {
    // excute when the tab is selected

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {

        tabIndex = tabBarController.selectedIndex
        print("tab!! \(tabIndex)")
    }
    
}


