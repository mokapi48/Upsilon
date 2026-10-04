#ifndef HOME_APP_H
#define HOME_APP_H

#include <escher.h>
#include "controller.h"
#include "../shared/shared_app.h"

namespace Home {

class App : public ::App {
public:
  class Descriptor : public ::App::Descriptor {
  public:
    I18n::Message name() override;
    I18n::Message upperName() override;
  };
  class Snapshot : public ::SharedApp::Snapshot, public SelectableTableViewDataSource {
  public:
    App * unpack(Container * container) override;
    Descriptor * descriptor() override;
  };
  void redraw();
  virtual void didBecomeActive(Window * window);
  static App * app() {
    return static_cast<App *>(Container::activeApp());
  }
  Snapshot * snapshot() const {
    return static_cast<Snapshot *>(::App::snapshot());
  }
  TELEMETRY_ID("Home");
#if HOME_DISPLAY_EXTERNALS
  int heapSize() { return k_externalHeapSize; }
  char * heap() { return m_externalHeap; }

  #pragma GCC diagnostic push
  #pragma GCC diagnostic ignored "-Winvalid-offsetof"
  static constexpr size_t externalHeapOffset() { return offsetof(App, m_externalHeap); }
  #pragma GCC diagnostic pop

  /* Raised from 107674 (and Poincare TreePool shrunk accordingly, see
   * poincare/include/poincare/tree_pool.h) so external apps such as the
   * Peanut-GBC emulator get enough heap for their WRAM/VRAM/cart-RAM buffers. */
  static constexpr int k_externalHeapSize = 119450;
#endif
private:
  App(Snapshot * snapshot);
  Controller m_controller;
#if HOME_DISPLAY_EXTERNALS
  char m_externalHeap[k_externalHeapSize];
#endif
  Window * m_window;
};

}

#endif
