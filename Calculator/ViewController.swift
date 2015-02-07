//
//  ViewController.swift
//  Calculator
//
//  Created by Priyanjana Bengani on 31/01/2015.
//  Copyright (c) 2015 anothercookiecrumbles. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // IBOutlet – just to show what the property is connected to.
    // weak – memory management happens within Swift using ARC. 
    // Objects only live on the heap; always a pointer. 
    // ! – Nullable (or initialised to nil by default)
    // ! – is an implicitly wrapped optional. Essentially syntactic sugar.
    // ? - Optional
    @IBOutlet weak var display: UILabel!;
    
    // All properties must be initialised. There are two ways of 
    // doing this: 
    // a) Using an initialiser 
    // b) Initialising in-line at the point of method declaration
    var userIsInTheMiddleOfTypingANumber: Bool = false;
    
    // You don't have to duplicate the type.
    // var operandStack: Array<Double> = Array<Double>();
    // With the below, the type is inferred.
    var operandStack = Array<Double>();
    
    var displayValue: Double {
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue;
        }
        set {
            display.text = "\(newValue)";
            self.userIsInTheMiddleOfTypingANumber = false;
        }
    }

    @IBAction func appendDigit(sender: UIButton) {
        // let is the equivalent of final; digit can never change
        // unwrap the value from the Optional by using "!"
        // if the "!" isn't there, digit is an Optional.
        // if the currentTitle is nil, everything goes boom.
        let digit = sender.currentTitle!;
        if userIsInTheMiddleOfTypingANumber {
            display.text = display.text! + digit;
        } else {
            display.text = digit;
            self.userIsInTheMiddleOfTypingANumber = true;
        }
    }
    
    @IBAction func enter() {
        self.userIsInTheMiddleOfTypingANumber = false;
        operandStack.append(displayValue);
        println("operandStack = \(operandStack)");
    }
    
    @IBAction func operate(sender: UIButton) {
        let operation = sender.currentTitle!;
        if userIsInTheMiddleOfTypingANumber {
            enter();
        }
        switch operation {
        case "×": performOperation {$0 * $1};
                break;
        case "÷": performOperation {$1 / $0};
                break;
        case "+": performOperation {$0 + $1};
                break;
        case "−": performOperation {$1 - $0};
                break;
        case "√": performOperation {sqrt($0)};
        default: break;
        }
    }
    
    func performOperation(operation: (Double, Double) -> Double) {
        if operandStack.count >= 2 {
            displayValue = operation(operandStack.removeLast(), operandStack.removeLast());
            enter();
        }
    }
    
    func performOperation(operation: Double -> Double) {
        if operandStack.count >= 1 {
            displayValue = operation(operandStack.removeLast());
            enter();
        }
    }
}