package org.weather;

import java.io.File;
import java.io.IOException;
import java.net.ProxySelector;
import java.util.HashMap;
import java.util.List;
import java.util.prefs.Preferences;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.Marshaller;
import javax.xml.bind.Unmarshaller;

import org.controlsfx.dialog.Dialogs;
import org.weather.ui.controller.RootLayoutController;
import org.weather.ui.controller.WeatherOverviewController;
import org.weather.ui.model.DownloadWeather;
import org.weather.ui.model.ParseXml;
import org.weather.ui.model.Weather;
import org.weather.ui.model.WeatherListWrapper;

import com.btr.proxy.search.ProxySearch;

import javafx.application.Application;
import javafx.collections.FXCollections;
import javafx.collections.ObservableList;
import javafx.fxml.FXMLLoader;
import javafx.scene.Scene;
import javafx.scene.image.Image;
import javafx.scene.layout.AnchorPane;
import javafx.scene.layout.BorderPane;
import javafx.stage.Modality;
import javafx.stage.Stage;

/**
 * @param args 
 * @throws
 */
public class Weather extends Application {
	// A static instance to the running application
    private Stage primaryStage;
    private BorderPane rootLayout;
    /**
     * The data as an observable list of Weather.
     */
    private ObservableList<Weather> weatherData = FXCollections.observableArrayList();

	public Weather() throws Exception {
		//ProxySearch proxySearch = ProxySearch.getDefaultProxySearch();
//	   	ProxySearch.main(null);
	
		//ProxySelector myProxySelector = proxySearch.getProxySelector();
		//ProxySelector.setDefault(myProxySelector);

		DownloadWeather dw = new DownloadWeather();
		ParseXml px = new ParseXml();
		System.out.print(dw.getWeather("4429").toString());
		List<Weather> w = px.parseWeather(dw.getWeather("4429"));
		weatherData.addAll(w);
    
/*	for(Weather iw: w) {
		iw.Print();
	}
*/
	}

    public static void main(String[] args) {
        launch(args);
    }

    @Override
    public void start(Stage primaryStage) {
        this.primaryStage = primaryStage;
        this.primaryStage.setTitle("Weather");

        this.primaryStage.getIcons().add(new Image("file:resources/images/Rp5.png"));

        initRootLayout();
        showWeatherOverview();
    }

    /**
     * Returns the data as an observable list of weather. 
     * @return
     */
    public ObservableList<Weather> getWeatherData() {
        return weatherData;
    }

	/**
	 * Initializes the root layout and tries to load the last opened city
	 * 
	 */
   	public void initRootLayout() {
	    try {
	        // Load root layout from fxml file.
	        FXMLLoader loader = new FXMLLoader();
	        loader.setLocation(Weather.class
	                .getResource("ui/view/RootLayout.fxml"));
	        rootLayout = (BorderPane) loader.load();

	        // Show the scene containing the root layout.
	        Scene scene = new Scene(rootLayout);
	        primaryStage.setScene(scene);

	        // Give the controller access to the main app.
	        RootLayoutController controller = loader.getController();
	        controller.setMainApp(this);

	        primaryStage.show();
	    } catch (IOException e) {
	        e.printStackTrace();
	    }

	    // Try to load last opened person file.
	    File file = getWeatherFilePath();
	    if (file != null) {
	        loadWeatherDataFromFile(file);
	    }
    }

    /**
     * Shows the Weather overview inside the root layout.
     */
    public void showWeatherOverview() {
        try {
            // Load person overview.
            FXMLLoader loader = new FXMLLoader();
            loader.setLocation(Weather.class.getResource("ui/view/WeatherOverview.fxml"));
            AnchorPane weatherOverview = (AnchorPane) loader.load();

            // Set person overview into the center of root layout.
            rootLayout.setCenter(weatherOverview);

            // Give the controller access to the main app.
            WeatherOverviewController controller = loader.getController();
            controller.setMainApp(this);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    /**
     * Returns the main stage.
     * @return
     */
    public Stage getPrimaryStage() {
        return primaryStage;
    }

    /**
     * Returns the Weather file preference, i.e. the file that was last opened.
     * The preference is read from the OS specific registry. If no such
     * preference can be found, null is returned.
     * 
     * @return
     */
    public File getWeatherFilePath() {
        Preferences prefs = Preferences.userNodeForPackage(Weather.class);
        String filePath = prefs.get("filePath", null);
        if (filePath != null) {
            return new File(filePath);
        } else {
            return null;
        }
    }

    /**
     * Sets the file path of the currently loaded file. The path is persisted in
     * the OS specific registry.
     * 
     * @param file the file or null to remove the path
     */
    public void setWeatherFilePath(File file) {
        Preferences prefs = Preferences.userNodeForPackage(Weather.class);
        if (file != null) {
            prefs.put("filePath", file.getPath());

            // Update the stage title.
            primaryStage.setTitle("Weather - " + file.getName());
        } else {
            prefs.remove("filePath");

            // Update the stage title.
            primaryStage.setTitle("Weather");
        }
    }

    /**
     * Loads Weather data from the specified file. The current weather data will
     * be replaced.
     * 
     * @param file
     */
    public void loadWeatherDataFromFile(File file) {
        try {
            JAXBContext context = JAXBContext
                    .newInstance(WeatherListWrapper.class);
            Unmarshaller um = context.createUnmarshaller();

            // Reading XML from the file and unmarshalling.
            WeatherListWrapper wrapper = (WeatherListWrapper) um.unmarshal(file);

            weatherData.clear();
            weatherData.addAll(wrapper.getWeather());

            // Save the file path to the registry.
            setWeatherFilePath(file);

        } catch (Exception e) { // catches ANY exception
            Dialogs.create()
                    .title("Error")
                    .masthead("Could not load data from file:\n" + file.getPath())
                    .showException(e);
        }
    }

    /**
     * Saves the current Weather data to the specified file.
     * 
     * @param file
     */
    public void savePersonDataToFile(File file) {
        try {
            JAXBContext context = JAXBContext
                    .newInstance(WeatherListWrapper.class);
            Marshaller m = context.createMarshaller();
            m.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, true);

            // Wrapping our person data.
            WeatherListWrapper wrapper = new WeatherListWrapper();
            wrapper.setWeather(weatherData);

            // Marshalling and saving XML to the file.
            m.marshal(wrapper, file);

            // Save the file path to the registry.
            setWeatherFilePath(file);
        } catch (Exception e) { // catches ANY exception
            Dialogs.create().title("Error")
                    .masthead("Could not save data to file:\n" + file.getPath())
                    .showException(e);
        }
    }
}