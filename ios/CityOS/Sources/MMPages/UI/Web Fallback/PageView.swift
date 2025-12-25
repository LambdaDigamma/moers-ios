//
//  PageView.swift
//
//
//  Created by Lennart Fischer on 02.01.21.
//

#if canImport(WebKit)

import SwiftUI
import ModernNetworking

public struct PageView: View {
    
    @ObservedObject var viewModel: PageViewModel
    @StateObject var webViewStateModel: WebViewStateModel = WebViewStateModel()
    
    public var body: some View {
        
        viewModel.urlRequest.isLoading {
            
            ProgressView()
                .progressViewStyle(.circular)
            
        }
        
        viewModel.urlRequest.hasResource { (request: URLRequest) in
            
            ZStack {
                
                WebView(
                    uRLRequest: request,
                    webViewStateModel: webViewStateModel,
                    onNavigationAction: nil
                )
                
                if webViewStateModel.loading {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
                
            }
            
        }
        
        viewModel.urlRequest.hasError { (error: Error) in
            
            Text("An error occured")
            
        }
        
        
//        if false {
//
//            ScrollView {
//                LazyVStack(alignment: .leading) {
//
//                    ForEach(blocks) { block in
//
//                        if block.type == "single-image" {
//
//                            Image("mf-2019-2")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(maxWidth: .infinity)
//                                .padding(.bottom, Margin.standard)
//
//                        }
//
//
//                    }
                    
//                AuthorView()
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding(.horizontal)
//                    .padding(.bottom, Margin.standard)
//                Text("Von Inseln, Parallelitäten und Zeitbandenkämpfen")
//                    .multilineTextAlignment(.leading)
//                    .font(Typography.style(.titleLarge))
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding(.horizontal)
//                    .padding(.bottom, Margin.standard)
//                Text("Edle Auserwählte, die vergangene 49. Ausgabe des moers festival hatten wir ursprünglich als aufwirbelnden Vorabend vor dem 50. Festivaljubiläum geplant. Und hatten nach dem Motto „Vorabende kündigen Veränderungen an“ ahnungsvoll angemerkt, dass es doch merkwürdig wäre, wenn danach alles einfach beim Alten bliebe...\n\nTja, jetzt ist rein gar nichts beim Alten geblieben. Shutdown, Lockdown-Leid und ein krachender kultureller Knockout.\n\nKapitänin Miss Unimoers hatte uns in diesem Jahr mutig hinaus in die raue See gebracht, durch wilde Untiefen manövriert, hat sich abstrampelnd, selbstpeitschend oder kniefallend aufgeopfert, um über 200 aus aller Welt angereiste Musikanten vor dem feuerspeienden Ungeheuer zu beschützen und wir alle durften dabei zusehen, wie sie stellvertretend für die moerswide vereinzelt versammelte PfingstjüngerInnenschar über 40 Konzerte lang aus der Festivalwerkstatthalle kreativen Impfstoff in die Welt gespreaded hat - new ways to fly.")
//                    .multilineTextAlignment(.leading)
//                    .font(Typography.style(.body))
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .foregroundColor(.secondary)
//                    .padding(.horizontal, Margin.wide)
//                    .padding(.bottom)
//                }
//            }
//
//        }
    }
    
}

struct PageView_Previews: PreviewProvider {
    static var previews: some View {
        
        Text("")
        
//        let viewModel = PageViewModel(pageService: , pageID: Page.ID)
//
//        NavigationView {
//            PageView(page: .constant(.loading))
//                .navigationBarTitle("", displayMode: .inline)
//        }.environment(\.colorScheme, .dark)
        
    }
}

#endif
