//
//  LineChartViewController.swift
//
//  Created by Aleksandr Makarov on 27.07.2018.
//  Copyright © 2018 Aleksandr Makarov. All rights reserved.
//

import UIKit

/** Класс реализует контроллер с графиком,
    выпадающим списком показателей,
    горизонтальным списком кнопок с периодами.
    Вид экземпляра класса необходимо добавить на родительский, задать виду фрейм.
    Для загрузки данных необходимо присвоить значение isin: */

protocol LineChartPresentable {
    /// График.
    var lineChart: LineChart! { get set }
    /** Идентификатор облигации.
        При повторном присваивании значения произойдет перезагрузка данных. */
    var isin: String? { get set }
}

class LineChartViewController: UIViewController, LineChartPresentable {

    // MARK: - LineChartPresentable

    /// Идентификатор облигации.
    public var isin: String? {
        didSet {
            if let viewModel = viewModel, let isin = self.isin {
                self.lineChart.clearAll()
                viewModel.fetchData(isin: isin)
            }
        }
    }
    /// График.
    public var lineChart: LineChart! {
        didSet {
            /// Внешний вид графика по протоколу LineChartViewPresentable можно настроить здесь.
            self.lineChart.y.grid.count = 5
        }
    }

    // MARK: -

    /// Выпадающий список.
    fileprivate var dropList: DropListViewController! {
        didSet {
            dropList.view.isHidden = true /// свернем пока нет данных
            dropList.selectedRow = { [unowned self] (index) in
                self.viewModel.dropListSelected(index)
            }
        }
    }
    /// Кнопки с периодами.
    fileprivate var bottomButtons: ButtonsViewController! {
        didSet {
            bottomButtons.selectedIndex = { [unowned self] (index) in
                self.viewModel.bottomButtonsSelected(index)
            }
        }
    }
    /// Индикатор активности.
    fileprivate var activityView: UIActivityIndicatorView! {
        didSet {
            self.activityView.activityIndicatorViewStyle = .gray
            self.activityView.hidesWhenStopped = true
        }
    }
    /// Модель.
    fileprivate var viewModel: LineChartViewModelPresentable! {
        didSet {
            /// выпадающий список
            viewModel.updateDropListTitles = { [unowned self] (value) in
                self.dropList.view.isHidden = false
                self.dropList.setDataSource(value)
            }
            /// кнопки с периодами
            viewModel.updateBottomButtonTitles = { [unowned self] (value) in
                self.bottomButtons.dataSource = value
            }
            /// текущий индекс кнопок с периодами
            viewModel.updateBottomButtonsIndex = { [unowned self] (value) in
                self.bottomButtons.currentIndex = value
            }
            /// лейбы на оси x
            viewModel.updateXAxisTitles = { [unowned self] (value) in
                self.lineChart.x.grid.count = value.count
                self.lineChart.x.labels.values = value
                self.lineChart.setNeedsDisplay()
            }
            /// данные графика
            viewModel.updateData = { [unowned self] (value) in
                self.lineChart.clearAll()
                self.lineChart.addLine(value)
            }
            /// идет обновление данных
            viewModel.refreshData = { [unowned self] (value) in
                if value {
                    self.activityView.startAnimating()
                } else {
                    self.activityView.stopAnimating()
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        /// добавим элементы
        self.lineChart = LineChart()
        self.dropList = DropListViewController()
        self.bottomButtons = ButtonsViewController()
        self.activityView = UIActivityIndicatorView()

        self.view.addSubview(self.lineChart)
        self.view.addSubview(self.dropList.view)
        self.view.addSubview(self.bottomButtons.view)
        self.view.addSubview(self.activityView)

        addViewConstraints()

        /// запросим данные
        self.viewModel = LineChartViewModel()

        if let isin = self.isin {
            self.viewModel.fetchData(isin: isin)
        }
    }

    fileprivate func addViewConstraints() {
        let dropListWidth: CGFloat = 100
        let dropListHeight: CGFloat = 35
        let dropListTop: CGFloat = 10
        let dropListLeading: CGFloat = 20
        let bottomButtonsHeight: CGFloat = 45

        let guide = self.view.safeAreaLayoutGuide

        self.lineChart.translatesAutoresizingMaskIntoConstraints = false
        self.lineChart.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        self.lineChart.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
        self.lineChart.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
        self.lineChart.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -bottomButtonsHeight).isActive = true

        self.dropList.view.translatesAutoresizingMaskIntoConstraints = false
        self.dropList.view.topAnchor.constraint(equalTo: guide.topAnchor, constant: dropListTop).isActive = true
        self.dropList.view.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: dropListLeading).isActive = true
        self.dropList.view.widthAnchor.constraint(equalToConstant: dropListWidth).isActive = true
        self.dropList.view.heightAnchor.constraint(equalToConstant: dropListHeight).isActive = true
        self.dropList.maxHeight = self.view.bounds.height - dropListTop - dropListHeight - 100 /// отступ снизу
        
        self.bottomButtons.view.translatesAutoresizingMaskIntoConstraints = false
        self.bottomButtons.view.topAnchor.constraint(equalTo: self.lineChart.bottomAnchor).isActive = true
        self.bottomButtons.view.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
        self.bottomButtons.view.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
        self.bottomButtons.view.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true

        self.activityView.translatesAutoresizingMaskIntoConstraints = false
        self.activityView.centerXAnchor.constraint(equalTo: self.lineChart.centerXAnchor).isActive = true
        self.activityView.centerYAnchor.constraint(equalTo: self.lineChart.centerYAnchor).isActive = true
    }

    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        /// Изменили ориентацию устройства. Перерисуем график, свернем список.
        self.lineChart.setNeedsDisplay()
        self.dropList.hide()
    }
}
