//
//  BroadcastList.swift
//  
//
//  Created by Lennart Fischer on 23.09.21.
//

import SwiftUI
import Combine
import Nuke
import NukeUI

public struct BroadcastList: View {
    
    @ObservedObject private var viewModel: BroadcastListViewModel
    
    public init(
        viewModel: BroadcastListViewModel
    ) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        
        ScrollView {
            
            VStack(alignment: .leading, spacing: 0) {
                
                header()
                    .padding(.bottom, 24)
                
                nextBroadcasts()
                
//                pastBroadcasts()
                
                Text(AppStrings.Buergerfunk.disclaimer)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
                
            }
            
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.load()
        }
        
    }
    
    @ViewBuilder
    private func header() -> some View {
        
        VStack(alignment: .leading, spacing: 12) {
            
            Text(AppStrings.Buergerfunk.title)
                .font(.title2.weight(.semibold))
            
            Text(AppStrings.Buergerfunk.description)
                .font(.callout)
                .foregroundColor(.secondary)
            
            Button(action: {}) {
                Text("\(Image(systemName: "envelope.circle.fill")) \(AppStrings.Buergerfunk.contactAction)")
            }
            .buttonStyle(SecondaryButtonStyle())
            .padding(.top)
            
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    @ViewBuilder
    private func nextBroadcasts() -> some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            HStack(alignment: .firstTextBaseline) {
                
                Text(AppStrings.Buergerfunk.nextBroadcasts)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Spacer()
                
//                Button(action: {
//
//                }) {
//                    Text("\(AppStrings.Buergerfunk.allAction) \(Image(systemName: "chevron.forward"))")
//                        .font(.body.weight(.medium))
//                        .foregroundColor(.yellow)
//                }
                
            }
            .padding(.bottom, 20)
            
            ForEach(viewModel.viewModels) { broadcast in
                
                NavigationLink {
                    BroadcastDetail(
                        viewModel: broadcast,
                        listenNowAction: {},
                        toggleReminderAction: {
                            
                        }
                    )
                } label: {
                    BroadcastRow(viewModel: broadcast)
                        .padding(.vertical, 8)
                }
                
//                Divider().padding(.leading, 44 + 8)
                
            }
            
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        
    }
    
    @ViewBuilder
    private func pastBroadcasts() -> some View {
        
        VStack(alignment: .leading) {
            
            Button {
                
            } label: {
                Text("\(AppStrings.Buergerfunk.listenToPastBroadcasts) \(Image(systemName: "chevron.forward"))")
                    .padding(.horizontal)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(Color(UIColor.label))
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                LazyHStack(spacing: 16) {
                    
                    BroadcastCard(
                        source: "https://www.nrwision.de/fileadmin/_processed_assets_/4/3/csm_thumb_buergerradiomeerbeck_a_02_2021.mp3_09fb752572.jpg",
                        title: "Bürgerradio Meerbeck"
                    )
                    
                    BroadcastCard(
                        source: "https://www.nrwision.de/fileadmin/_processed_assets_/7/0/csm_thumb_vhsmoers_01_2021.mp3_54c7364f8e.jpg",
                        title: "VHS Moers"
                    )
                    
                    BroadcastCard(
                        source: "https://www.nrwision.de/fileadmin/_processed_assets_/3/8/csm_thumb_kulturreportmoers_01_2021.mp3_6b34923de8.jpg",
                        title: "Kulturreport Moers"
                    )
                    
                }
                .padding(.horizontal)
                
            }
            
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
        .padding(.top)
        
    }
    
}

struct BroadcastList_Preview: PreviewProvider {
    
    static var previews: some View {
        
        let viewModel = BroadcastListViewModel(service: StaticRadioService())
        
        NavigationView {
            BroadcastList(viewModel: viewModel)
        }
        .preferredColorScheme(.dark)
        
    }
    
}
