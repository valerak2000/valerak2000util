package org.zebra.ui;

import org.eclipse.jface.viewers.ILabelProviderListener;
import org.eclipse.jface.viewers.ITableLabelProvider;
import org.eclipse.swt.graphics.Image;

/**
 * This class provides the labels for Zebra table
 */
public class ZebraLabelProvider implements ITableLabelProvider {
  /**
   * Returns the image
   * 
   * @param element the element
   * @param columnIndex the column index
   * @return Image
   */
  public Image getColumnImage(Object element, int columnIndex) {
    return null;
  }

  /**
   * Returns the column text
   * 
   * @param element the element
   * @param columnIndex the column index
   * @return String
   */
  public String getColumnText(Object element, int columnIndex) {
    ZebraLabel zebras = (ZebraLabel) element;
 
    switch (columnIndex) {
    case 0:
      return zebras.getGoods_name();
    case 1:
      return zebras.getGoods_barcode();
    case 2:
      return zebras.getNumber_copies().toString();
    }
    return null;
  }

  /**
   * Adds a listener
   * 
   * @param listener the listener
   */
  public void addListener(ILabelProviderListener listener) {
  // Ignore it
  }

  /**
   * Disposes any created resources
   */
  public void dispose() {
  // Nothing to dispose
  }

  /**
   * Returns whether altering this property on this element will affect the label
   * 
   * @param element the element
   * @param property the property
   * @return boolean
   */
  public boolean isLabelProperty(Object element, String property) {
    return false;
  }

  /**
   * Removes a listener
   * 
   * @param listener the listener
   */
  public void removeListener(ILabelProviderListener listener) {
  // Ignore
  }
}