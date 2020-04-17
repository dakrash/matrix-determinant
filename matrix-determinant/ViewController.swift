//
//  ViewController.swift
//  matrix-determinant
//
//  Created by darya on 16.04.2020.
//  Copyright © 2020 darya. All rights reserved.
//

import UIKit

class ViewController: UIViewController{
    
    let scrollView = UIScrollView()
    
    var currentСapacity : Int = 0
    
    let minCapacity : Int = 3
    
    let maxCapacity : Int = 20
    
    let matrixView : UIStackView = {
        let result = UIStackView()
        result.axis = .vertical
        result.spacing = 5
        return result
    }()
    
    var textField : UITextField {
        get{
            let result = UITextField()
            result.borderStyle = UITextField.BorderStyle.roundedRect
            result.keyboardType = .numbersAndPunctuation
            result.insetsLayoutMarginsFromSafeArea = false
            result.delegate = self
            result.autocorrectionType = .no
            NSLayoutConstraint.activate([
                result.heightAnchor.constraint(equalToConstant: 60),
                result.widthAnchor.constraint(equalToConstant: 60)
            ])
            return result
        }
    }
    
    var row : UIStackView {
        get {
            let result = UIStackView()
            result.axis = .horizontal
            result.spacing = 5
            for _ in 0...currentСapacity - 1 {
                result.addArrangedSubview(textField)
            }
            return result
        }
    }
    
    let determinantLabel = UILabel()
    
    let currentCapacityLabel = UILabel()
    
    var activeTextField : UITextField?
    
    var lastOffset : CGFloat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
        currentСapacity = minCapacity
        setCapacityLabelText()
        let stepperLabel : UILabel = {
            let label = UILabel()
            label.text = "Изменить разрядность:"
            return label
        }()
        let stepper : UIStepper = {
            let stepper = UIStepper()
            stepper.stepValue = 1.0
            stepper.value = Double(currentСapacity)
            stepper.minimumValue = Double(minCapacity)
            stepper.maximumValue = Double(maxCapacity)
            stepper.addTarget(self, action: #selector(countChanged(_ :)), for: .valueChanged)
            return stepper
        }()
        let submit : UIButton = {
            let button = UIButton(type: .system)
            button.setTitle("Найти определитель", for: .normal)
            button.addTarget(self, action: #selector(calculate), for: .touchUpInside)
            return button
        }()
        for _ in 0...currentСapacity - 1 {
            self.matrixView.addArrangedSubview(row)
        }
        self.view.addSubview(stepperLabel)
        stepperLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(currentCapacityLabel)
        currentCapacityLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(stepper)
        stepper.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(submit)
        submit.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(determinantLabel)
        determinantLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(matrixView)
        matrixView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stepperLabel.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor),
            stepperLabel.centerYAnchor.constraint(equalTo: stepper.centerYAnchor),
            stepper.leadingAnchor.constraint(equalTo: stepperLabel.trailingAnchor, constant: 8),
            stepper.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor, constant: 8),
            currentCapacityLabel.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor),
            currentCapacityLabel.topAnchor.constraint(equalTo: stepper.bottomAnchor, constant: 8),
            scrollView.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: currentCapacityLabel.bottomAnchor, constant: 8),
            submit.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.view.layoutMarginsGuide.bottomAnchor.constraint(equalTo: determinantLabel.bottomAnchor, constant: 8),
            submit.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 8),
            determinantLabel.topAnchor.constraint(equalTo: submit.bottomAnchor, constant: 8),
            determinantLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            matrixView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            matrixView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            matrixView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            matrixView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    @objc func calculate(){
        let matrix = matrixView.arrangedSubviews.reduce(into: [[Double]]()) { (result, view) in
            guard let rowView = view as? UIStackView else {return}
            var row = [Double]()
            rowView.arrangedSubviews.forEach { (view) in
                guard let textField = view as? UITextField, let text = textField.text else {return}
                guard let doubleValue = Double(text) else {return}
                row.append(doubleValue)
            }
            result.append(row)
        }
        guard let determinant = self.determinant(matrix) else {
            let alert = UIAlertController(title: "Данные введенны неверно", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        let determinantStr = String(determinant)
        let formatteddeterminantStr = String(format: "Определитель: %.8f", determinant)
        determinantLabel.text = formatteddeterminantStr.count < determinantStr.count ? formatteddeterminantStr : determinantStr
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue, let activeTextField = self.activeTextField {
            guard let globalPoint = activeTextField.superview?.convert(activeTextField.frame.origin, to: nil) else {return}
            let distanceAtBottom = self.view.frame.maxY - (globalPoint.y + activeTextField.frame.height)
            let offset = keyboardSize.height - distanceAtBottom
            if offset > -20 {
                lastOffset = offset
                self.scrollView.contentOffset = CGPoint(x: self.scrollView.contentOffset.x, y: self.scrollView.contentOffset.y + offset)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
            if let lastOffset = self.lastOffset {
                self.scrollView.contentOffset = CGPoint(x: self.scrollView.contentOffset.x, y: self.scrollView.contentOffset.y - lastOffset)
                self.lastOffset = nil
            }
    }
    
    @objc func countChanged(_ stepper : UIStepper!) {
        if let value = Int(exactly: stepper.value) {
            if value != currentСapacity {
                determinantLabel.text = nil
                let different = value - currentСapacity
                currentСapacity = value
                setCapacityLabelText()
                matrixView.arrangedSubviews.forEach { (view) in
                    for _ in 0...abs(different) - 1 {
                        if different > 0 {
                            (view as? UIStackView)?.addArrangedSubview(textField)
                        } else {
                            (view as? UIStackView)?.arrangedSubviews.last?.removeFromSuperview()
                        }
                    }
                }
                for _ in 0...abs(different) - 1 {
                    if different > 0 {
                        matrixView.addArrangedSubview(row)
                    } else {
                        matrixView.arrangedSubviews.last?.removeFromSuperview()
                    }
                }
            }
        }
    }
    
    func setCapacityLabelText() {
        currentCapacityLabel.text = "Текущая разрядность : \(self.currentСapacity)"
    }
    
    func determinant(_ matrix: [[Double]]) -> Double? {
        if matrix.count < 2 || matrix.first(where: { (column) -> Bool in
            return column.count != matrix.count
        }) != nil {
            return nil
        }
        if matrix.count == 2 {
            let result = matrix[0][0] * matrix[1][1] - matrix[0][1] * matrix[1][0]
            return result
        } else {
            var result : Double = 0
            for colIndex in 0...matrix.count - 1 {
                var matr = matrix
                let val = matr[0][colIndex]
                matr.remove(at: 0)
                for rowIndex in 0...matr.count - 1 {
                    matr[rowIndex].remove(at: colIndex)
                }
                guard let min = determinant(matr) else {return nil}
                result += Double(truncating: pow(-1, 1 + (colIndex + 1)) as NSDecimalNumber) * val * min
            }
            return result
        }
    }
}
