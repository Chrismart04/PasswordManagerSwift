import SwiftUI
import AppKit
import Combine

class MenuBarManager: ObservableObject {
    @Published var isPopoverShown: Bool = false
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    
    init() {
        setupMenuBar()
    }
    
    private func setupMenuBar() {
        // Crear el item en la barra de menú
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "key.fill", accessibilityDescription: "Password Manager")
            button.action = #selector(togglePopover)
            button.target = self
        }
        
        // Configurar el popover
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 350, height: 500)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: MenuBarContentView())
    }
    
    @objc private func togglePopover() {
        guard let popover = popover, let button = statusItem?.button else { return }
        
        if popover.isShown {
            popover.performClose(nil)
            isPopoverShown = false
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            isPopoverShown = true
        }
    }
    
    func hidePopover() {
        popover?.performClose(nil)
        isPopoverShown = false
    }
}
