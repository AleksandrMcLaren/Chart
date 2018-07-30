//
//  LineChartViewModel.swift
//
//  Created by Aleksandr Makarov on 27.07.2018.
//  Copyright © 2018 Aleksandr Makarov. All rights reserved.
//

import UIKit

protocol LineChartViewModelPresentable: class {
    /// Обновляет данные выпадающего списка.
    var updateDropListTitles: (([String]) -> Void)? { get set }
    /// Обновляет данные кнопок периодов.
    var updateBottomButtonTitles: (([String]) -> Void)? { get set }
    /// Выделяет кнопку периода.
    var updateBottomButtonsIndex: ((Int) -> Void)? { get set }
    /// Обновляет данные лейб по оси x
    var updateXAxisTitles: (([String]) -> Void)? { get set }
    /// Обновляет данные графика.
    var updateData: (([CGFloat]) -> Void)? { get set }
    /// Сообщает о загрузке данных.
    var refreshData: ((Bool) -> Void)? { get set }

    /// Получить данные.
    func fetchData(isin: String)
    /// Сообщает о новом выбранном индексе выпадающего списка.
    func dropListSelected(_ index: Int)
    /// Сообщает о новом выбранном индексе кнопок периодов.
    func bottomButtonsSelected(_ index: Int)
}

class LineChartViewModel: LineChartViewModelPresentable {

    // MARK: - LineChartViewModelPresentable

    public var updateDropListTitles: (([String]) -> Void)?
    public var updateBottomButtonTitles: (([String]) -> Void)?
    public var updateBottomButtonsIndex: ((Int) -> Void)?
    public var updateXAxisTitles: (([String]) -> Void)?
    public var updateData: (([CGFloat]) -> Void)?
    public var refreshData: ((Bool) -> Void)?

    public func fetchData(isin: String) {
        /// симулируем запрос данных
        self.refreshData?(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.downloadData(isin: isin, completion: { [weak self] in
                self?.refreshData?(false)
            })
        }
    }

    public func dropListSelected(_ index: Int) {
        self.state.dropListIndex = index
        performCurrentData()
    }

    public func bottomButtonsSelected(_ index: Int) {
        self.state.bottomButtonsIndex = index
        performCurrentData()
    }

    // MARK: -

    /// Хранит списки данных.
    fileprivate var listData = [ChartListData]()
    /// Хранит по умолчанию/выбранные пользователем состояния кнопок.
    fileprivate var state = LineChartState()
    /// Применить данные по текущим состояниям.
    fileprivate func performCurrentData() {
        if self.state.dropListIndex < self.listData.count {
            let currentListData = self.listData[self.state.dropListIndex]
            if self.state.bottomButtonsIndex < currentListData.dataPeriods.count {
                let currentData = currentListData.dataPeriods[self.state.bottomButtonsIndex]
                self.updateXAxisTitles?(currentData.xAxisTitles)
                self.updateData?(currentData.dataPoint)
            }
        }
    }
}

extension LineChartViewModel {

    func downloadData(isin: String, completion: (() -> Void)?) {
        let parseQueue = DispatchQueue(label: "LineChartViewModel.downloadData")
        parseQueue.async {
            /// создадим данные кнопок
            let dropListTitles = ["YIELD", "PRICE"]
            let bottomButtonTitles = ["1W", "1M", "3M", "6M", "1Y", "2Y"]
            /// создадим данные графиков
            let yield = ChartListData()
            let price = ChartListData()
            self.listData.append(yield)
            self.listData.append(price)
            /// отправим данные контроллеру
            DispatchQueue.main.async {
                self.updateDropListTitles?(dropListTitles)
                self.updateBottomButtonTitles?(bottomButtonTitles)
                self.updateBottomButtonsIndex?(self.state.bottomButtonsIndex)
                self.performCurrentData()
                completion?()
            }
        }
    }
}
