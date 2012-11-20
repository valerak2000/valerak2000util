package org.zebra.ui.view;

import org.eclipse.jface.action.*;
import org.zebra.ui.Zebra;

/**
 * This action class exits the application
 */
public class ExitAction extends Action {
  /**
   * ExitAction constructor
   */
  public ExitAction() {
    super(Zebra.getApp().getConfZebra().getString("Exit"), Zebra.getApp().getImageFor("exit"));
//    setToolTipText("Exit");
  }

  /**
   * Exits the application
   */
  public void run() {
    Zebra.getApp().close();
  }
}