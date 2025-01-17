package org.zebra.ui.view;

import org.eclipse.jface.viewers.*;

/**
 * This class implements the sorting for the Player Table
 */
public class ZebraViewerSorter extends ViewerSorter {
  private static final int ASCENDING = 0;
  private static final int DESCENDING = 1;

  private int column;
  private int direction;

  /**
   * Does the sort. If it's a different column from the previous sort, do an
   * ascending sort. If it's the same column as the last sort, toggle the sort
   * direction.
   * 
   * @param column
   */
  public void doSort(int column) {
    if (column == this.column) {
      // Same column as last sort; toggle the direction
      direction = 1 - direction;
    } else {
      // New column; do an ascending sort
      this.column = column;
      direction = ASCENDING;
    }
  }

  /**
   * Compares the object for sorting
   */
  public int compare(Viewer viewer, Object e1, Object e2) {
    int rc = 0;
    Player p1 = (Player) e1;
    Player p2 = (Player) e2;

    // Determine which column and do the appropriate sort
    switch (column) {
    case PlayerConst.COLUMN_FIRST_NAME:
      rc = collator.compare(p1.getFirstName(), p2.getFirstName());
      break;
    case PlayerConst.COLUMN_LAST_NAME:
      rc = collator.compare(p1.getLastName(), p2.getLastName());
      break;
    case PlayerConst.COLUMN_POINTS:
      rc = p1.getPoints() > p2.getPoints() ? 1 : -1;
      break;
    case PlayerConst.COLUMN_REBOUNDS:
      rc = p1.getRebounds() > p2.getRebounds() ? 1 : -1;
      break;
    case PlayerConst.COLUMN_ASSISTS:
      rc = p1.getAssists() > p2.getAssists() ? 1 : -1;
      break;
    }

    // If descending order, flip the direction
    if (direction == DESCENDING) rc = -rc;

    return rc;
  }
}