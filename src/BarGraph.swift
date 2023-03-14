//
//  BarGraph.swift
//  Appanalytics
//
//  Created by Nirbhay Jain on 10/05/22.
//

import SwiftUI


struct BarGraph: View {
    
    var downloads: [Result]
    var value : String
    var decider : Bool
    
    
    //MARK: Gesture Properties
    @GestureState var isDragging:Bool = false
    @State var offset: CGFloat = 0
    
    //MARK: current download to highlight while draggin
    @State var currentDownloadID: String = ""
    
    
    var body: some View {    
        
        HStack{
            
            ForEach(downloads.indices, id: \.self){ index in
                
                if index == downloads.count-1 {
                    
                    if value == "revenue" || value == "earnings"{

                        Text("\( String(format: "%.2f", Double(downloads[index].stringProperty(for: value))!) )")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                            

                    }
                    else
                    {
                        Text("\(Int(downloads[index].intProperty(for: value)))")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                        
                            
                    }
                }
                
            }
            
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
        
        HStack {
            Text("Today")
                .foregroundColor(Color.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
        HStack(spacing:8){
            
            
            ForEach(downloads.indices, id: \.self){ index in
                
                VStack(spacing: 20){
                    GeometryReader{proxy in
                        
                        let size = proxy.size
                        
                        RoundedRectangle(cornerRadius: 6)
                            .fill( index % 2 == 0 ? Color("green") : Color("purple"))
                            .opacity(isDragging ? (currentDownloadID == downloads[index].id ? 1 : 0.35) : 1)
                            .frame(
                                    height: getMax() == CGFloat(0)
                                    ? 0.0
                                    : (CGFloat(downloads[index].intProperty(for: value)) / getMax()) * CGFloat(size.height)
                            )
                            .overlay( decider
                                      ? AnyView(Text("\( String(format: "%.2f", Double(downloads[index].stringProperty(for: value))!) )")
                                        .font(.system(size: 13))
                                        .font(.callout)
                                        .foregroundColor(index % 2 == 0 ? Color("green") : Color("purple"))
                                        .opacity(isDragging && currentDownloadID == downloads[index].id ? 1: 0)
                                        .offset(y : -30))
                                      
                                      : AnyView(Text("\(Int(downloads[index].intProperty(for: value)))")
                                        .font(.system(size: 13))
                                        .font(.callout)
                                        .foregroundColor(index % 2 == 0 ? Color("green") : Color("purple"))
                                        .opacity(isDragging && currentDownloadID == downloads[index].id ? 1: 0)
                                        .offset(y : -30))
                                      
                                      
                                      ,alignment: .top
                            )
                            .frame(maxHeight: .infinity, alignment: .bottom)
                    }
                    
                    Text( (downloads[index].date).suffix(2) )
                        .font(.callout)
                        .foregroundColor( currentDownloadID == downloads[index].id ? Color("tab") : .gray)
                    
                    
                }
                
            }
            
        }
        .frame(height: 150)
        .animation(.easeOut, value:isDragging)
        .padding(.top,20)
        .padding(.bottom,20)
        
        //MARK: Gesture
        
        .gesture(
            
            DragGesture()
                .updating($isDragging, body: { _, out, _ in
                    out = true
                })
                .onChanged({ value in
                    
                    // MARK: only updating if draggin
                    offset = isDragging ? value.location.x : 0
                    
                    // dragging space removing the padding added to the view...
                    //total padding = 60
                    // 2 * 15 Horizontal
                    
                    let draggingSpace = UIScreen.main.bounds.width - 60
                    
                    
                    //Each Block
                    let eachBlock =  draggingSpace / CGFloat(downloads.count)
                    
                    
                    //getting Index
                    let temp = Int(offset / eachBlock)
                    
                    //Safe Wrapping index..
                    let index = max(min(temp, downloads.count - 1 ), 0)
                    
                    //Updating ID
                    self.currentDownloadID = downloads[index].id
                    
                })
                .onEnded({ value in
                    
                    withAnimation{
                        offset = .zero
                        currentDownloadID = ""
                    }
                })
        )
        
        
//        HStack {
//            Text("May")
//        }
        
    }
    
    //to get the Graph height
    //getting max in the downloads
    
    func getMax()->CGFloat {
        let max = downloads.max { first, second in
            return second.intProperty(for: value) > first.intProperty(for: value)
            
        }
        return CGFloat(max?.intProperty(for: value) ?? 0)
    }
    
    
}



struct BarGraph_Previews: PreviewProvider {
    static var previews: some View {
        Home()
    }
}
