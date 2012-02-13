package org.zebra.ui;

import java.util.ArrayList;
import java.util.List;

/**
 * This class contains the data model for the ZebraTable
 */
public enum ZebraTableModel {
    INSTANCE;  
    private List<ZebraLabel> labels;  

  /**
   * Constructs a PlayerTableModel Fills the model with data
   */
    private ZebraTableModel() {
    	labels = new ArrayList<ZebraLabel>();  
    	// Image here some fancy database access to read the persons and to  
    	// put them into the model  
    	labels.add(new ZebraLabel("Rainer", "Zufall", 1));  
    	labels.add(new ZebraLabel("Reiner", "Babbel", 1));  
    	labels.add(new ZebraLabel("Marie", "Dortmund", 1));  
    	labels.add(new ZebraLabel("Holger", "Adams", 1));  
    	labels.add(new ZebraLabel("Juliane", "Adams", 1));  
    }  

	public List<ZebraLabel> getLabels() {  
		return labels;  
	}  
}