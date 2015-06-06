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
    
    @IBOutlet weak var history: UILabel!;
    
    // All properties must be initialised. There are two ways of 
    // doing this: 
    // a) Using an initialiser 
    // b) Initialising in-line at the point of method declaration
    var userIsInTheMiddleOfTypingANumber: Bool = false;
    
    // You don't have to duplicate the type.
    // var operandStack: Array<Double> = Array<Double>();
    // With the below, the type is inferred.
    var operandStack = Array<Double>();
    
    var brain = CalculatorBrain();
    
    let numberFormatter = NSNumberFormatter();
    
    var displayValue: Double? {
        get {
            if let displayText = display.text {
                if let displayNumber = numberFormatter.numberFromString(displayText) {
                    return displayNumber.doubleValue;
                }
            }
            return nil
        }
        set {
            if (newValue != nil) {
                numberFormatter.numberStyle = .DecimalStyle;
                numberFormatter.maximumFractionDigits = 4;
                display.text! = numberFormatter.stringFromNumber(newValue!)!;
            } else {
                display.text! = "0";
            }
            self.userIsInTheMiddleOfTypingANumber = false;
            if let stack = brain.unravelStack() {
                history.text = stack;
            }
        }
    }

    @IBAction func appendDigit(sender: UIButton) {
        // let is the equivalent of final; digit can never change
        // unwrap the value from the Optional by using "!"
        // if the "!" isn't there, digit is an Optional.
        // if the currentTitle is nil, everything goes boom.
        let digit = sender.currentTitle!;
        if userIsInTheMiddleOfTypingANumber {
            if digit == "." {
                if let displayedValue = display.text {
                    if displayedValue.rangeOfString(".") != nil {
                        println("Adding a decimal point when a decimal point already exists");
                        return;
                    }
                }
            }
            display.text = display.text! + digit;
        } else {
            if digit == "." {
                display.text = "0.";
            } else {
                display.text = digit;
            }
            self.userIsInTheMiddleOfTypingANumber = true;
            history.text = brain.unravelStack();
        }
        
    }
    
    @IBAction func clear(sender: UIButton) {
        brain.empty();
        displayValue = 0;
        history.text = "0.0";
    }
    
    @IBAction func backspace(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            if let displayedValue = display.text {
                if count(displayedValue) > 0 {
                    display.text = dropLast(display.text!);
                }
            }
        } else {
            display.text = "0.0";
        }
    }
    
    @IBAction func enter() {
        self.userIsInTheMiddleOfTypingANumber = false;
        if let result = brain.pushOperand(displayValue!) {
            displayValue = result;
        } else {
            displayValue = 0;
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        let operation = sender.currentTitle!;
        if userIsInTheMiddleOfTypingANumber {
            if operation == "±" {
                if let displayText = display.text {
                    if displayText[displayText.startIndex] == "-"  {
                        display.text = dropFirst(displayText);
                    } else {
                        display.text = "-" + displayText;
                    }
                return
                }
            }

            enter();
        }
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
                displayValue = result;
                history.text = history.text! + " = ";
            } else {
                displayValue = 0;
            }
        }
    }
    
    private func performOperation(operation: (Double, Double) -> Double) {
        if operandStack.count >= 2 {
            displayValue = operation(operandStack.removeLast(), operandStack.removeLast());
            enter();
        }
    }
    
    private func performOperation(operation: Double -> Double) {
        if operandStack.count >= 1 {
            displayValue = operation(operandStack.removeLast());
            enter();
        }
    }
}