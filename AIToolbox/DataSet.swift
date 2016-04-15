//
//  DataSet.swift
//  AIToolbox
//
//  Created by Kevin Coble on 12/6/15.
//  Copyright © 2015 Kevin Coble. All rights reserved.
//

import Foundation


public enum DataSetType   //  data type
{
    case Regression
    case Classification
}

enum DataTypeError: ErrorType {
    case InvalidDataType
    case DataWrongForType
    case WrongDimensionOnInput
    case WrongDimensionOnOutput
}

enum DataIndexError: ErrorType {
    case Negative
    case IndexAboveDimension
    case IndexAboveDataSetSize
}


public class DataSet {
    let dataType : DataSetType
    let inputDimension: Int
    let outputDimension: Int
    var inputs: [[Double]]
    var outputs: [[Double]]?
    var classes: [Int]?
    var optionalData: AnyObject?        //  Optional data that can be temporarily added by methods using the data
    
    public init(dataType : DataSetType, inputDimension : Int, outputDimension : Int)
    {
        //  Remember the data parameters
        self.dataType = dataType
        self.inputDimension = inputDimension
        self.outputDimension = outputDimension
        
        //  Allocate data arrays
        inputs = []
        if (dataType == .Regression) {
            outputs = []
        }
        else {
            classes = []
        }
    }
    
    public init(fromDataSet: DataSet)
    {
        //  Remember the data parameters
        self.dataType = fromDataSet.dataType
        self.inputDimension = fromDataSet.inputDimension
        self.outputDimension = fromDataSet.outputDimension
        
        //  Copy data arrays
        inputs = fromDataSet.inputs
        outputs = fromDataSet.outputs
        classes = fromDataSet.classes
    }
   
    public init?(fromDataSet: DataSet, withEntries: [Int])
    {
        //  Remember the data parameters
        self.dataType = fromDataSet.dataType
        self.inputDimension = fromDataSet.inputDimension
        self.outputDimension = fromDataSet.outputDimension
        
        //  Allocate data arrays
        inputs = []
        if (dataType == .Regression) {
            outputs = []
        }
        else {
            classes = []
        }
        
        //  Copy the entries
        do {
            try includeEntries(fromDataSet: fromDataSet, withEntries: withEntries)
        }
        catch {
            return nil
        }
    }
    
    public func includeEntries(fromDataSet fromDataSet: DataSet, withEntries: [Int]) throws
    {
        //  Make sure the dataset matches
        if dataType != fromDataSet.dataType { throw DataTypeError.InvalidDataType }
        if inputDimension != fromDataSet.inputDimension { throw DataTypeError.WrongDimensionOnInput }
        if outputDimension != fromDataSet.outputDimension { throw DataTypeError.WrongDimensionOnOutput }
        
        //  Copy the entries
        for index in withEntries {
            if (index  < 0) { throw DataIndexError.Negative }
            if (index  >= fromDataSet.size) { throw DataIndexError.IndexAboveDataSetSize }
            inputs.append(fromDataSet.inputs[index])
            if (dataType == .Regression) {
                outputs!.append(fromDataSet.outputs![index])
            }
            else {
                classes!.append(fromDataSet.classes![index])
                if outputs != nil {
                    outputs!.append(fromDataSet.outputs![index])
                }
            }
        }
    }
    
    public var size: Int
    {
        return inputs.count
    }
    
    public func singleOutput(index: Int) -> Double?
    {
        //  Validate the index
        if (index < 0) { return nil}
        if (index >= inputs.count) { return nil }
        
        //  Get the data
        if (dataType == .Regression) {
            return outputs![index][0]
        }
        else {
            return Double(classes![index])
        }
    }
    
    public func addDataPoint(input input : [Double], output: [Double]) throws
    {
        //  Validate the data
        if (dataType != .Regression) { throw DataTypeError.DataWrongForType }
        if (input.count != inputDimension) { throw DataTypeError.WrongDimensionOnInput }
        if (output.count != outputDimension) { throw DataTypeError.WrongDimensionOnOutput }
        
        //  Add the new data item
        inputs.append(input)
        outputs!.append(output)
    }
    
    public func addDataPoint(input input : [Double], output: Int) throws
    {
        //  Validate the data
        if (dataType != .Classification) { throw DataTypeError.DataWrongForType }
        if (input.count != inputDimension) { throw DataTypeError.WrongDimensionOnInput }
        
        //  Add the new data item
        inputs.append(input)
        classes!.append(output)
    }
    
    public func setOutput(index: Int, newOutput : [Double]) throws
    {
        //  Validate the data
        if (dataType != .Regression) { throw DataTypeError.DataWrongForType }
        if (index < 0) { throw  DataIndexError.Negative }
        if (index > inputs.count) { throw  DataIndexError.Negative }
        if (newOutput.count != outputDimension) { throw DataTypeError.WrongDimensionOnOutput }
        
        //  Add the new output item
        outputs![index] = newOutput
    }
    
    public func setClass(index: Int, newClass : Int) throws
    {
        //  Validate the data
        if (dataType != .Classification) { throw DataTypeError.DataWrongForType }
        if (index < 0) { throw  DataIndexError.Negative }
        if (index > inputs.count) { throw  DataIndexError.Negative }
        
        classes![index] = newClass
    }
    
    public func addUnlabeledDataPoint(input input : [Double]) throws
    {
        //  Validate the data
        if (input.count != inputDimension) { throw DataTypeError.WrongDimensionOnInput }
        
        //  Add the new data item
        inputs.append(input)
    }
    public func addTestDataPoint(input input : [Double]) throws
    {
        //  Validate the data
        if (input.count != inputDimension) { throw DataTypeError.WrongDimensionOnInput }
        
        //  Add the new data item
        inputs.append(input)
    }
    
    public func getInput(index: Int) throws ->[Double]
    {
        //  Validate the data
        if (index < 0) { throw  DataIndexError.Negative }
        if (index > inputs.count) { throw  DataIndexError.IndexAboveDataSetSize }
        
        return inputs[index]
    }
    
    public func getOutput(index: Int) throws ->[Double]
    {
        //  Validate the data
        if (dataType != .Regression) { throw DataTypeError.DataWrongForType }
        if (index < 0) { throw  DataIndexError.Negative }
        if (index > outputs!.count) { throw  DataIndexError.IndexAboveDataSetSize }
        
        return outputs![index]
    }
   
    public func getClass(index: Int) throws ->Int
    {
        //  Validate the data
        if (dataType != .Classification) { throw DataTypeError.DataWrongForType }
        if (index < 0) { throw  DataIndexError.Negative }
        if (index > classes!.count) { throw  DataIndexError.IndexAboveDataSetSize }
        
        return classes![index]
    }
    
    public func getRandomIndexSet() -> [Int]
    {
        //  Get the ordered array of indices
        var shuffledArray: [Int] = []
        for i in 0..<inputs.count - 1 { shuffledArray.append(i) }
        
        // empty and single-element collections don't shuffle
        if size < 2 { return shuffledArray }
        
        //  Shuffle
        for i in 0..<inputs.count - 1 {
            let j = Int(arc4random_uniform(UInt32(inputs.count - i))) + i
            guard i != j else { continue }
            swap(&shuffledArray[i], &shuffledArray[j])
        }
        
        return shuffledArray
    }
    
    public func getInputRange() -> [(minimum: Double, maximum: Double)]
    {
        //  Allocate the array of tuples
        var results : [(minimum: Double, maximum: Double)] = Array(count: inputDimension, repeatedValue: (minimum: Double.infinity, maximum: -Double.infinity))
        
        //  Go through each input
        for input in inputs {
            //  Go through each dimension
            for dimension in 0..<inputDimension {
                if (input[dimension] < results[dimension].minimum) { results[dimension].minimum = input[dimension] }
                if (input[dimension] > results[dimension].maximum) { results[dimension].maximum = input[dimension] }
            }
        }
        
        return results
    }
    
    public func getOutputRange() -> [(minimum: Double, maximum: Double)]
    {
        //  Allocate the array of tuples
        var results : [(minimum: Double, maximum: Double)] = Array(count: outputDimension, repeatedValue: (minimum: Double.infinity, maximum: -Double.infinity))
        
        //  If no outputs, return invalid range
        if (outputs == nil) { return results }
        
        //  Go through each output
        for output in outputs! {
            //  Go through each dimension
            for dimension in 0..<outputDimension {
                if (output[dimension] < results[dimension].minimum) { results[dimension].minimum = output[dimension] }
                if (output[dimension] > results[dimension].maximum) { results[dimension].maximum = output[dimension] }
            }
        }
        
        return results
    }
    
    //  Leave here in case it is used by other methods
    public static func gaussianRandom(mean : Double, standardDeviation : Double) -> Double
    {
        return Gaussian.gaussianRandom(mean, standardDeviation: standardDeviation)
    }
}
