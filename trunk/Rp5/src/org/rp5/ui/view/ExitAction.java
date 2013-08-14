package org.rp5.ui.view;

import org.eclipse.jface.action.*;
import org.rp5.Rp5;

/**
 * This action class exits the application
 */
public class ExitAction extends Action {
  /**
   * ExitAction constructor
   */
  public ExitAction() {
    super("Exit", Rp5.getApp().getImageFor("exit"));
//    setToolTipText("Exit");
  }

  /**
   * Exits the application
   */
  public void run() {
	  Rp5.getApp().close();
  }
}