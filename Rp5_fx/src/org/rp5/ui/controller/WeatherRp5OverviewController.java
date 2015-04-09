package org.rp5.ui.controller;

import java.text.DateFormat;

import javafx.beans.property.SimpleStringProperty;
import javafx.fxml.FXML;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableView;
import java.text.SimpleDateFormat;

import org.rp5.Rp5;
import org.rp5.ui.model.WeatherRp5;


public class WeatherRp5OverviewController {
    @FXML
    private TableView<WeatherRp5> weatherRp5Table;
    @FXML
    private TableColumn<WeatherRp5, Integer> timeStepColumn;
    @FXML
    private TableColumn<WeatherRp5, String> dateTimeColumn;
    @FXML
    private TableColumn<WeatherRp5, String> gColumn;
    @FXML
    private TableColumn<WeatherRp5, String> hhiiColumn;
    @FXML
    private TableColumn<WeatherRp5, Integer> cloudCoverColumn;
    @FXML
    private TableColumn<WeatherRp5, Double> precipitationColumn;
    @FXML
    private TableColumn<WeatherRp5, Integer> pressureColumn;
    @FXML
    private TableColumn<WeatherRp5, Integer> temperatureColumn;
    @FXML
    private TableColumn<WeatherRp5, Integer> humidityColumn;
    @FXML
    private TableColumn<WeatherRp5, String> windDirectionColumn;
    @FXML
    private TableColumn<WeatherRp5, Integer> windVelocityColumn;
    @FXML
    private TableColumn<WeatherRp5, Integer> fallsColumn;
    @FXML
    private TableColumn<WeatherRp5, Integer> dropsColumn;

    // Reference to the main application.
    private Rp5 mainApp;

    /**
     * The constructor.
     * The constructor is called before the initialize() method.
     */
    public WeatherRp5OverviewController() {
    }

    /**
     * Initializes the controller class. This method is automatically called
     * after the fxml file has been loaded.
     */
    @FXML
    private void initialize() {
        // Initialize the person table with the two columns.
    	timeStepColumn.setCellValueFactory(cellData -> cellData.getValue().timeStepProperty().asObject());
/*    	dateTimeColumn.setCellValueFactory(new PropertyValueFactory<WeatherRp5, Date>("dateTime"));
    	dateTimeColumn.setCellValueFactory(new Callback<CellDataFeatures<WeatherRp5, Date>, ObservableValue<Date>>() {
            @Override public ObservableValue<Date> call(CellDataFeatures<WeatherRp5, Date> p) {
                return new ReadOnlyObjectWrapper<Date>(new Date(p.getValue().getDateTime().toString()));
            }
        });
*/
    	dateTimeColumn.setCellValueFactory(
    			cellData -> {
    			      SimpleStringProperty property = new SimpleStringProperty();
    			      DateFormat dateFormat = new SimpleDateFormat("dd.MM.yyyy HH:mm");
    			      property.setValue(dateFormat.format(cellData.getValue().getDateTime()));
    			      return property;
    			   });
        /*birthdayColumn.setComparator(new Comparator<String>(){
        @Override 
        public int compare(String t, String t1) {
        	try{
        		SimpleDateFormat dateFormat = new SimpleDateFormat("dd.MM.yyyy");
                Date d1 = dateFormat.parse(t);                
                Date d2 = dateFormat.parse(t1);
                return Long.compare(d1.getTime(), d2.getTime());
        	}catch(ParseException p){
                p.printStackTrace();
        	}
        	return -1;
             
        }
        
   });*/

    	gColumn.setCellValueFactory(cellData -> cellData.getValue().gProperty());
        hhiiColumn.setCellValueFactory(cellData -> cellData.getValue().hhiiProperty());
        cloudCoverColumn.setCellValueFactory(cellData -> cellData.getValue().cloudCoverProperty().asObject());
        precipitationColumn.setCellValueFactory(cellData -> cellData.getValue().precipitationProperty().asObject());
        pressureColumn.setCellValueFactory(cellData -> cellData.getValue().pressureProperty().asObject());
        temperatureColumn.setCellValueFactory(cellData -> cellData.getValue().temperatureProperty().asObject());
        humidityColumn.setCellValueFactory(cellData -> cellData.getValue().humidityProperty().asObject());
        windDirectionColumn.setCellValueFactory(cellData -> cellData.getValue().windDirectionProperty());
        windVelocityColumn.setCellValueFactory(cellData -> cellData.getValue().windVelocityProperty().asObject());
        fallsColumn.setCellValueFactory(cellData -> cellData.getValue().fallsProperty().asObject());
        dropsColumn.setCellValueFactory(cellData -> cellData.getValue().dropsProperty().asObject());

        // Clear weather details.
        showWeatherRp5Details(null);
        // Listen for selection changes and show the person details when changed.
        weatherRp5Table.getSelectionModel().selectedItemProperty().addListener(
                (observable, oldValue, newValue) -> showWeatherRp5Details(newValue));
    }

    /**
     * Is called by the main application to give a reference back to itself.
     * 
     * @param mainApp
     */
    public void setMainApp(Rp5 mainApp) {
        this.mainApp = mainApp;

        // Add observable list data to the table
        weatherRp5Table.setItems(mainApp.getWeatherRp5Data());
    }
    
    /**
     * Fills all text fields to show details about the weather.
     * If the specified weather is null, all text fields are cleared.
     * 
     * @param weatherRp5 or null
     */
    private void showWeatherRp5Details(WeatherRp5 weatherRp5) {
    }
}
