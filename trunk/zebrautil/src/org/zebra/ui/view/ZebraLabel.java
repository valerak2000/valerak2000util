package org.zebra.ui.view;  
  
import java.beans.PropertyChangeListener;  
import java.beans.PropertyChangeSupport;  
import java.util.Collections;
import java.util.List;
  
public class ZebraLabel {  
    private String goods_name;  
    private String goods_barcode;  
    private Integer number_copies;  
    private List labels;
    private PropertyChangeSupport propertyChangeSupport = new PropertyChangeSupport(  
            this);  
  
    public ZebraLabel() {  
    }  
  
    public ZebraLabel(String goods_name, String goods_barcode, Integer number_copies) {  
        super();  
        this.goods_name = goods_name;  
        this.goods_barcode = goods_barcode;  
        this.number_copies = number_copies;  
    }  
  
    public void addPropertyChangeListener(String propertyName, PropertyChangeListener listener) {  
        propertyChangeSupport.addPropertyChangeListener(propertyName, listener);  
    }  
  
    public void removePropertyChangeListener(PropertyChangeListener listener) {  
        propertyChangeSupport.removePropertyChangeListener(listener);  
    }  
  
    public String getGoods_name() {  
        return goods_name;  
    }  
  
    public String getGoods_barcode() {  
        return goods_barcode;  
    }  
  
    public Integer getNumber_copies() {  
        return number_copies;  
    }  
  
    public void setGoods_name(String goods_name) {  
        propertyChangeSupport.firePropertyChange("goods_name", this.goods_name,  
                this.goods_name = goods_name);  
    }  
  
    public void setGoods_barcode(String goods_barcode) {  
        propertyChangeSupport.firePropertyChange("goods_barcode", this.goods_barcode,  
                this.goods_barcode = goods_barcode);  
    }  
  
    public void setNumber_copies(Integer number_copies) {  
        propertyChangeSupport.firePropertyChange("number_copies", this.number_copies,  
                this.number_copies = number_copies);  
    }  

    public List getLabels() {
        return Collections.unmodifiableList(labels);
    }
  
    @Override  
    public String toString() {  
        return goods_name + " " + goods_barcode + " " + number_copies;  
    }  
  
}  