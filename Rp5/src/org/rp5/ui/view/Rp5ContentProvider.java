package org.rp5.ui.view;

import java.util.List;

import org.eclipse.jface.viewers.IStructuredContentProvider;
import org.eclipse.jface.viewers.Viewer;

/**
 * This class provides the content for the person table
 */
public class Rp5ContentProvider implements IStructuredContentProvider {
  /**
   * Returns the Person objects
   */
  public Object[] getElements(Object inputElement) {
	return null;
//    List<ZebraLabel> list = (List<ZebraLabel>) inputElement;
//	return list.toArray();
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
  @Override
  public void inputChanged(Viewer viewer, Object oldInput, Object newInput) {
  // Ignore
  }

}