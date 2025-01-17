package org.zebra.ui.view;

import java.util.List;

import org.eclipse.jface.viewers.IStructuredContentProvider;
import org.eclipse.jface.viewers.Viewer;

/**
 * This class provides the content for the person table
 */
public class ZebraContentProvider implements IStructuredContentProvider {
  /**
   * Returns the Person objects
   */
  public Object[] getElements(Object inputElement) {
    List<ZebraLabel> list = (List<ZebraLabel>) inputElement;
	return list.toArray();
  }

  /**
   * Disposes any created resources
   */
  public void dispose() {
  // Do nothing
  }

  /**
   * Called when the input changes
   */
  public void inputChanged(Viewer viewer, Object oldInput, Object newInput) {
  // Ignore
  }
}