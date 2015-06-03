//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Priyanjana Bengani on 02/06/2015.
//  Copyright (c) 2015 anothercookiecrumbles. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    private enum Op : Printable {
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        case Operand(Double)
        case ZilchOperation(String, () -> Double)
        
        var description: String {
            get {
                switch self {
                case .UnaryOperation(let symbol, _):
                    return symbol;
                case .BinaryOperation(let symbol, _):
                    return symbol;
                case .Operand(let operand):
                    return "\(operand)";
                case .ZilchOperation(let symbol, _):
                    return symbol;
                }
            }
        }
    }
    
    private var opStack = [Op](); // Declares an array; same as Array<Op>
    
    private var knownOps = [String:Op](); // same as Dictionary<String, Op>();
    
    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op;
        }
        // Move operations to constants.
        learnOp(Op.BinaryOperation("×") { $0 * $1 });
        learnOp(Op.BinaryOperation("÷") { $1 / $0 });
        learnOp(Op.BinaryOperation("+") { $0 + $1 });
        learnOp(Op.BinaryOperation("−") { $1 - $0 });
        learnOp(Op.UnaryOperation("√", sqrt));
        learnOp(Op.UnaryOperation("sin", sin));
        learnOp(Op.UnaryOperation("cos", cos));
        learnOp(Op.ZilchOperation("π", { M_PI }))
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand));
        return evaluate();
    }
    
    func empty() {
        self.opStack.removeAll(keepCapacity: true); 
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] { // Dictionary always returns an Optional.
            opStack.append(operation);
        }
        return evaluate();
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack);
        println("\(opStack) = \(result) with \(remainder) left over.");
        return result;
    }
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops; // The ops parameter is immutable so creating a local copy. The alternative would be to add "var" as the qualifier for the input parameter.
            let op = remainingOps.removeLast();
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps);
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps);
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps);
                }
            case .ZilchOperation(_, let operation):
                return (operation(), remainingOps);
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps);
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps);
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps);
                    }
                }
            }
            
        }
        return (nil, ops);
    }
    
    func unravelStack() -> String? {
        return " ".join(opStack.map({ "\($0)" }));
    }
    
}