//
//  ViewController + extension.swift
//  matrix-determinant
//
//  Created by darya on 17.04.2020.
//  Copyright © 2020 darya. All rights reserved.
//

import UIKit
extension ViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if text.count > 0 {
            if Double(text) == nil && text != "-" {
                return false
            }
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeTextField = nil
    }
    
}
