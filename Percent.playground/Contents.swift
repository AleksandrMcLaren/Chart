
import Foundation
import PlaygroundSupport

var str = "Hello!"

func genRandom(min: Double, max: Double) -> Double {
    return Double(arc4random()) / 0xFFFFFFFF * (max - min) + min
}

func roundToDecimal(_ value: Double, scale: Int) -> Decimal {
    var valueDecimal = Decimal(value)
    var roundedValue = Decimal()
    NSDecimalRound(&roundedValue, &valueDecimal, scale, NSDecimalNumber.RoundingMode.plain)
    return roundedValue
}

let scale = 3
let countValues = 500
let minValue: Double = 0.5
let maxValue: Double = 10

let randomValues = (1...countValues).map{_ in genRandom(min: minValue, max: maxValue)}
let sumValues = randomValues.reduce(0, +)
let percentValue = sumValues / 100

var percents = [Decimal]()
for value in randomValues {
    let percent = value / percentValue
    let roundedPercent = roundToDecimal(percent, scale: scale)
    percents.append(roundedPercent)
}

//print(percents)

let testPercentSum = percents.reduce(0, +)
print(testPercentSum)


/**
 *   Если нужно чтобы были тысячные полностью (с нулями в конце), будут строки
 */

let formatter = NumberFormatter()
formatter.numberStyle = .decimal
formatter.maximumFractionDigits = scale
formatter.minimumFractionDigits = scale
formatter.roundingMode = .halfUp

var stringPercents = [String]()
for value in randomValues {
    let percent = value / percentValue
    if let roundedPercent = formatter.string(from: NSNumber(value: percent)) {
        stringPercents.append(roundedPercent)
    }
}

//print(stringPercents)
