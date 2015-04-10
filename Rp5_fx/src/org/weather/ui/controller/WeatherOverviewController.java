package org.weather.ui.controller;

import java.text.DateFormat;

import javafx.beans.property.SimpleStringProperty;
import javafx.fxml.FXML;
import javafx.scene.control.TableColumn;
import javafx.scene.control.TableView;

import java.text.SimpleDateFormat;

import org.weather.Weather;
import org.weather.ui.model.Weather;


public class WeatherOverviewController {
    @FXML
    private TableView<Weather> weatherTable;
    @FXML
    private TableColumn<Weather, Integer> timeStepColumn;
    @FXML
    private TableColumn<Weather, String> dateTimeColumn;
    @FXML
    private TableColumn<Weather, String> gColumn;
    @FXML
    private TableColumn<Weather, String> hhiiColumn;
    @FXML
    private TableColumn<Weather, Integer> cloudCoverColumn;
    @FXML
    private TableColumn<Weather, Double> precipitationColumn;
    @FXML
    private TableColumn<Weather, Integer> pressureColumn;
    @FXML
    private TableColumn<Weather, Integer> temperatureColumn;
    @FXML
    private TableColumn<Weather, Integer> humidityColumn;
    @FXML
    private TableColumn<Weather, String> windDirectionColumn;
    @FXML
    private TableColumn<Weather, Integer> windVelocityColumn;
    @FXML
    private TableColumn<Weather, Integer> fallsColumn;
    @FXML
    private TableColumn<Weather, Integer> dropsColumn;

    // Reference to the main application.
    private Weather mainApp;

    /**
     * The constructor.
     * The constructor is called before the initialize() method.
     */
    public WeatherOverviewController() {
    }

    /**
     * Initializes the controller class. This method is automatically called
     * after the fxml file has been loaded.
     */
    @FXML
    private void initialize() {
        // Initialize the person table with the two columns.
    	timeStepColumn.setCellValueFactory(cellData -> cellData.getValue().timeStepProperty().asObject());
/*    	dateTimeColumn.setCellValueFactory(new PropertyValueFactory<Weather, Date>("dateTime"));
    	dateTimeColumn.setCellValueFactory(new Callback<CellDataFeatures<Weather, Date>, ObservableValue<Date>>() {
            @Override public ObservableValue<Date> call(CellDataFeatures<Weather, Date> p) {
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
        showWeatherDetails(null);
        // Listen for selection changes and show the person details when changed.
        weatherTable.getSelectionModel().selectedItemProperty().addListener(
                (observable, oldValue, newValue) -> showWeatherDetails(newValue));
    }

    /**
     * Is called by the main application to give a reference back to itself.
     * 
     * @param mainApp
     */
    public void setMainApp(Weather mainApp) {
        this.mainApp = mainApp;

        // Add observable list data to the table
        weatherTable.setItems(mainApp.getWeatherData());
    }
    
    /**
     * Fills all text fields to show details about the weather.
     * If the specified weather is null, all text fields are cleared.
     * 
     * @param weather or null
     */
    private void showWeatherDetails(Weather weather) {
    }
}
