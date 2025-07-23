import SwiftUI

struct TabBarView1: View {
    @Binding var isShow: Bool
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 70, style: .continuous)
                .fill(colorScheme == .light ? Color.hex("0C7B93").opacity(0.8) : Color("NewBlack1"))
                .shadow(color: .gray.opacity(0.4), radius: 20, x: 0, y: 20)
            
            TabsLayoutView(isShow: $isShow)
        }
        .frame(height: 50, alignment: .center)
    }
}

private struct TabsLayoutView: View {
    @State var selectedTab: Tab = .search
    @Namespace var namespace
    @Binding var isShow: Bool
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        HStack {
            Spacer(minLength: 0)
            
            ForEach(Tab.allCases) { tab in
                TabButton(tab: tab, selectedTab: $selectedTab, namespace: namespace, isShow: $isShow)
                    .frame(width: 80, height: 60, alignment: .center)
                
                Spacer(minLength: 0)
            }
        }
    }
    
    private struct TabButton: View {
        let tab: Tab
        @Binding var selectedTab: Tab
        var namespace: Namespace.ID
        @Binding var isShow: Bool
        @EnvironmentObject var vm:MapViewModel
        @EnvironmentObject var uiStateVm:UIStateViewModel
        @Environment(\.colorScheme) private var colorScheme
        @EnvironmentObject var settingsVm:SettingsViewModel
        var body: some View {
            Button {
                withAnimation {
                    selectedTab = tab
                    if tab == .chat{
                        uiStateVm.activeSheet = .chat
                    }
                    if tab == .settings{
//                        uiStateVm.activeSheet = .settingsView
                        settingsVm.isShow.toggle()
                    }
                    if tab == .search {  // Yalnızca seçili sekme "search" ise isShow'u tetikleyin
                        isShow.toggle()
                        uiStateVm.activeSheet = .search
                    }
                    if tab == .pharmacy{
                        uiStateVm.activeSheet = .pharmacyView
                    }
                    
                    hapticImpact.impactOccurred()
                }
            } label: {
//                ZStack {
//                    if isSelected {
//                        Circle()
//                            .fill(colorScheme == .light ? Color.hex("F2F2F7") : Color("NewBlack1")
//                           
//                            )
//                            .shadow(radius: 10)
//                            .background {
//                                Circle()
//                                    .stroke(lineWidth: 15)
//                                    .foregroundColor(colorScheme == .light ? Color("BabyBlue") : Color.hex("F2F2F7") )
//                            }
//                            .offset(y: -40)
//                            .matchedGeometryEffect(id: "Selected Tab", in: namespace)
//                            .animation(.spring(), value: selectedTab)
//                        
//                    }
//                    
//                    Image(systemName: tab.icon)
//                        .font(.system(size: 30, weight: .semibold, design: .rounded))
//                        .foregroundStyle(isSelected ? colorScheme == .light ? Color.hex("0C7B93"): Color.hex("F2F2F7") : colorScheme == .light ? Color.hex("F2F2F7"): Color.hex("F2F2F7"))
//                        
//                        .scaleEffect(isSelected ? 1 : 0.8)
//                        .offset(y: isSelected ? -40 : 0)
//                        .animation(isSelected ? .spring(response: 0.5, dampingFraction: 0.3, blendDuration: 1) : .spring(), value: selectedTab)
//                }
                VStack {
                    Image(systemName: tab.icon)
                        .font(.system(size: 25, weight: .regular))
                        .fontWeight(.medium)
                        .foregroundColor(selectedTab == tab ? (colorScheme == .light ? Color.hex("F2F2F7") : Color.hex("F2F2F7")) : (colorScheme == .light ? Color.hex("F2F2F7") : Color.hex("F2F2F7")))
                }
            }
            .buttonStyle(.plain)
        }
        
        private var isSelected: Bool {
            selectedTab == tab
        }
    }
}

#Preview {
    TabBarView1(isShow: .constant(false))
        .padding(.horizontal)
        .environmentObject(MapViewModel(locationManager: LocationManagerDummy()))
        .environmentObject(LocationManagerDummy())
        .environmentObject(RouteViewModel( locationManager: LocationManagerDummy()))
        .environmentObject(SearchViewModel())
}
