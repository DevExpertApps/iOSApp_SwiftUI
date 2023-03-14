//
//  Home.swift
//  Appanalytics
//
//  Created by Nirbhay Jain on 06/05/22.
//

import SwiftUI




struct Home: View {
    
    @AppStorage("onboarding") var onboarding = true
    
    @State var dataservice: [Result] = []
    
    
    @State private var pickerSelectedItem = 0
    
    @State private var selectedScreen: [String] = [ "clicks", "conversions", "revenue", "earnings"]
    @State private var conditionalSelector: [Bool] = [ false, false, true, true ]
    
    
    @StateObject var totalnumber: TotalNumber = TotalNumber()
    @StateObject var topaffiliates: TopAffiliatesAPI = TopAffiliatesAPI()
    
    
    
    init() {
        UITableView.appearance().separatorColor = .clear
        UITableView.appearance().backgroundColor = .clear
    }
    
    
    var body: some View {
        
        
        GeometryReader { reader in
            
            List {
                
                ZStack {
                    
                    VStack {
                        
                        HStack {
                            Text("last 7 days data,")
                                .font(.title2.bold())
                                .bold()
                            
                                Button( action: {
                                    
                                    
                                }) {
                                    
                                    Image(systemName: "questionmark.circle")
                                        .resizable()
                                        .frame(width: 10, height: 10)
                                        .foregroundColor(.gray)
                                        .offset(x: -10, y: -7)

                                    
                                }
                                

                            
                            Spacer()
                        }
                        
                        if dataservice == []
                        {
                            ProgressView("Loading...")
                                .font(.title2)
                                .padding(.top,50)
                        }
                        else{
                            
                            
                            HStack{
                                
                                CustomTabBottom(icon: "cursorarrow", title: String(Int(totalnumber.total_clicks)))
                                
                                Spacer()
                                CustomTabBottom(icon: "link", title: String(Int(totalnumber.total_conversions)))
                                
                            }
                            
                            HStack {
                                CustomTabBottom(icon: "dollarsign.circle", title: String(format: "%.2f", totalnumber.total_revenue))
                                Spacer()
                                CustomTabBottom(icon: "dollarsign.circle", title: String(format: "%.2f", totalnumber.total_earnings))
                            }
                        }
                        
                        
                        Divider()
                            .padding()
                        
                        Picker(selection: $pickerSelectedItem, label: Text("")) {
                            Text("Clicks").tag(0)
                            Text("Conversion").tag(1)
                            Text("Revenue").tag(2)
                            Text("Earnings").tag(3)
                        }.pickerStyle(SegmentedPickerStyle())
                            .padding(.top,10)
                        
                        
                        //MARK: Bar Graph with Gestures
                        
                        if dataservice == []
                        {
                            ProgressView("Loading...")
                                .font(.title2)
                                .padding(.top,50)
                        }
                        else{
                            
                            
                            BarGraph(downloads: dataservice, value: selectedScreen[pickerSelectedItem], decider: conditionalSelector[pickerSelectedItem])
                                .animation(.default)
                        }
                        
                        
                        Spacer()
                        
                        Divider()
                            .padding()
                        
                        HStack {
                            Text("Top Affiliates (By Earnings)")
                                .bold()
                        }
                        .padding()
                        
                        
                        if topaffiliates.mySymbols == [] {
                            
                            ProgressView("Loading...")
                                .font(.title2)
                                .padding(.top,50)
                            
                            
                        }
                        else {
                            
                            ForEach(topaffiliates.myValues.indices, id: \.self) { index in
                                
                                HStack {
                                    
                                    
                                    
//                                    Text("\( topaffiliates.mySymbols[index].components(separatedBy: " ")[1] )")
//                                        .font(.subheadline)
                                    Text("\( topaffiliates.mySymbols[index] )")
                                        .font(.subheadline)
                                    
                                    Spacer()
                                    
                                    
                                    
                                    Text("\( String(format: "%.2f", topaffiliates.myValues[index]) ) \("$")")
                                        .bold()
                                        .foregroundColor(.blue)
                                }
                                .padding()
                                
                            }
                            
                            
                        }
                        
                        
                        
                        
                    }
                    
                    
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    
                    
                    
                }
                
                .onAppear{
                    
                    let currenDate = getCurrentDate()
                    let past7DaysBeforeDate = past7dayDate(date1: currenDate)
                    
                    Task {
                        await StatsAPI().getStats(dateFrom: past7DaysBeforeDate, dateTo: currenDate) { (dataservice) in
                            self.dataservice = dataservice
                            
                            totalnumber.calc_total_clicks(downloads: dataservice)
                            
                            
                            topaffiliates.getTopAffiliates(dateFrom: currenDate, dateTo: currenDate)

                            
                        }
                        
                    }
                    
                    
                    
                }
                .listRowBackground(Color.black)
                
            }
            .shadow(color: Color.primary.opacity(0.2), radius: 10, x: 0, y: 5)
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .refreshable {
                let currenDate = getCurrentDate()
                let past7DaysBeforeDate = past7dayDate(date1: currenDate)
                
                Task {
                    await StatsAPI().getStats(dateFrom: past7DaysBeforeDate, dateTo: currenDate) { (dataservice) in
                        self.dataservice = dataservice
                        print("in Refreshable")
                        
                        totalnumber.calc_total_clicks(downloads: dataservice)
                        
                        topaffiliates.getTopAffiliates(dateFrom: currenDate, dateTo: currenDate)
                    }
                }
            }
            
        }
        
        
    }
    
    func past7dayDate(date1: String) -> String {
        let date = Date()
        let modifiedDate = Calendar.current.date(byAdding: .day, value: -6, to: date)!
        let calender = Calendar.current
        let day = calender.component(.day, from: modifiedDate)
        let month = calender.component(.month, from: modifiedDate)
        let year = calender.component(.year, from: modifiedDate)
        return "\(year)-\(month)-\(day)"
    }
    
    func getCurrentDate()-> String{
        let date = Date()
        let calender = Calendar.current
        let day = calender.component(.day, from: date)
        let month = calender.component(.month, from: date)
        let year = calender.component(.year, from: date)
        let currentDate = "\(year)-\(month)-\(day)"
        
        return currentDate
    }
    
    func CustomTabBottom(icon: String, title: String) -> some View {
        
        
        HStack {
            
            Image(systemName: icon)
                .font(.title3)
                .frame(width: 30, height: 30)
                .foregroundColor(.black)
                .background(
                    ZStack {
                        Color.white
                            .clipShape(Circle())
                    }
                )
            
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(.white)
                .fontWeight(.semibold)
        }
        .padding(.trailing, 16)
        
        .background(
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.purple, .cyan]), startPoint: .top, endPoint: .bottom)
                    .clipShape(Capsule())
            }
        )
        
    }
    
    
}


struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}


