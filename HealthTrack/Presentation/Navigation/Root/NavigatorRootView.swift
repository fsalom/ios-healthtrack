import SwiftUI

struct NavigatorRootView: View {
    @State var navigator: NavigatorProtocol
    let rootTransition: AnyTransition = .opacity
    private var deeplinkManager: DeepLinkManagerProtocol

    init(navigator: NavigatorProtocol = Navigator.shared,
         root: any View,
         deeplinkManager: DeepLinkManagerProtocol = DeepLinkManager.shared) {
        self.navigator = navigator
        self.deeplinkManager = deeplinkManager
        navigator.initialize(root: root)
    }

    var body: some View {
        NavigationStack(path: $navigator.path) {
            ZStack {
                if let root = navigator.root {
                    root.transition(rootTransition)
                }
            }
            .navigationDestination(for: Page.self) { page in
                page
            }
        }
        .animation(.default, value: navigator.root)
        .sheet(item: $navigator.sheet) { page in
            NestedSheetHost(navigator: navigator, content: page)
        }
        .alert(LocalizedStringKey(navigator.alertModel.title), isPresented: $navigator.isPresentingAlert) {
            AnyView(navigator.alertModel.style.buttons)
        } message: {
            Text(LocalizedStringKey(navigator.alertModel.message))
        }
        .overlay(
            VStack {
                Spacer()
                if let toastConfig = navigator.toastView {
                    AnyView(toastConfig)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                                withAnimation { navigator.toastView = nil }
                            }
                        }
                        .padding(.bottom, 8)
                }
            }
            .ignoresSafeArea(.keyboard)
        )
        .confirmationDialog("",
                            isPresented: $navigator.isPresentingConfirmationDialog,
                            titleVisibility: .hidden) {
            if let confirmationDialogConfig = navigator.confirmationDialogView {
                confirmationDialogConfig()
            }
        }
        .fullScreenCover(isPresented: $navigator.isPresentingFullOverScreen) {
            if let fullOverScreenConfig = navigator.fullOverScreenView {
                NestedFullScreenHost(navigator: navigator) {
                    AnyView(fullOverScreenConfig)
                }
            }
        }
    }
}
