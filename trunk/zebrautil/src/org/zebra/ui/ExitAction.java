package org.zebra.ui;

import org.eclipse.jface.action.*;

/**
 * This action class exits the application
 */
public class ExitAction extends Action {
  /**
   * ExitAction constructor
   */
  public ExitAction() {
    super(Zebra.getApp().getConfZebra().getMString("Exit"), Zebra.getApp().getImageFor("exit"));
//    setToolTipText("Exit");
  }

  /**
   * Exits the application
   */
  public void run() {
    Zebra.getApp().close();
  }
}