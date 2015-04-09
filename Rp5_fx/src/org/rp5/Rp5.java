package org.rp5;

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
import org.rp5.ui.controller.RootLayoutController;
import org.rp5.ui.controller.WeatherRp5OverviewController;
import org.rp5.ui.model.DownloadWeatherRp5;
import org.rp5.ui.model.ParseXml;
import org.rp5.ui.model.WeatherRp5;
import org.rp5.ui.model.WeatherRp5ListWrapper;

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
public class Rp5 extends Application {
	// A static instance to the running application
    private Stage primaryStage;
    private BorderPane rootLayout;
    /**
     * The data as an observable list of WeatherRp5.
     */
    private ObservableList<WeatherRp5> weatherRp5Data = FXCollections.observableArrayList();

	public Rp5() throws Exception {
		//ProxySearch proxySearch = ProxySearch.getDefaultProxySearch();
//	   	ProxySearch.main(null);
	
		//ProxySelector myProxySelector = proxySearch.getProxySelector();
		//ProxySelector.setDefault(myProxySelector);

		DownloadWeatherRp5 dwRp5 = new DownloadWeatherRp5();
		ParseXml px = new ParseXml();
		System.out.print(dwRp5.getWeather("4429").toString());
		List<WeatherRp5> wrp5 = px.parseWeather(dwRp5.getWeather("4429"));
		weatherRp5Data.addAll(wrp5);
    
/*	for(WeatherRp5 iwr5: wrp5) {
		iwr5.Print();
	}
*/
	}

    public static void main(String[] args) {
        launch(args);
    }

    @Override
    public void start(Stage primaryStage) {
        this.primaryStage = primaryStage;
        this.primaryStage.setTitle("Weather from Rp5");

        this.primaryStage.getIcons().add(new Image("file:resources/images/Rp5.png"));

        initRootLayout();
        showWeatherRp5Overview();
    }

    /**
     * Returns the data as an observable list of Persons. 
     * @return
     */
    public ObservableList<WeatherRp5> getWeatherRp5Data() {
        return weatherRp5Data;
    }

	/**
	 * Initializes the root layout and tries to load the last opened city
	 * 
	 */
   	public void initRootLayout() {
	    try {
	        // Load root layout from fxml file.
	        FXMLLoader loader = new FXMLLoader();
	        loader.setLocation(Rp5.class
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
	    File file = getWeatherRp5FilePath();
	    if (file != null) {
	        loadWeatherRp5DataFromFile(file);
	    }
    }

    /**
     * Shows the WeatherRp5 overview inside the root layout.
     */
    public void showWeatherRp5Overview() {
        try {
            // Load person overview.
            FXMLLoader loader = new FXMLLoader();
            loader.setLocation(Rp5.class.getResource("ui/view/WeatherRp5Overview.fxml"));
            AnchorPane weatherRp5Overview = (AnchorPane) loader.load();

            // Set person overview into the center of root layout.
            rootLayout.setCenter(weatherRp5Overview);

            // Give the controller access to the main app.
            WeatherRp5OverviewController controller = loader.getController();
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
     * Returns the WeatherRp5 file preference, i.e. the file that was last opened.
     * The preference is read from the OS specific registry. If no such
     * preference can be found, null is returned.
     * 
     * @return
     */
    public File getWeatherRp5FilePath() {
        Preferences prefs = Preferences.userNodeForPackage(Rp5.class);
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
    public void setWeatherRp5FilePath(File file) {
        Preferences prefs = Preferences.userNodeForPackage(Rp5.class);
        if (file != null) {
            prefs.put("filePath", file.getPath());

            // Update the stage title.
            primaryStage.setTitle("Weather from Rp5 - " + file.getName());
        } else {
            prefs.remove("filePath");

            // Update the stage title.
            primaryStage.setTitle("Weather from Rp5");
        }
    }

    /**
     * Loads WeatherRp5 data from the specified file. The current person data will
     * be replaced.
     * 
     * @param file
     */
    public void loadWeatherRp5DataFromFile(File file) {
        try {
            JAXBContext context = JAXBContext
                    .newInstance(WeatherRp5ListWrapper.class);
            Unmarshaller um = context.createUnmarshaller();

            // Reading XML from the file and unmarshalling.
            WeatherRp5ListWrapper wrapper = (WeatherRp5ListWrapper) um.unmarshal(file);

            weatherRp5Data.clear();
            weatherRp5Data.addAll(wrapper.getWeatherRp5());

            // Save the file path to the registry.
            setWeatherRp5FilePath(file);

        } catch (Exception e) { // catches ANY exception
            Dialogs.create()
                    .title("Error")
                    .masthead("Could not load data from file:\n" + file.getPath())
                    .showException(e);
        }
    }

    /**
     * Saves the current WeatherRp5 data to the specified file.
     * 
     * @param file
     */
    public void savePersonDataToFile(File file) {
        try {
            JAXBContext context = JAXBContext
                    .newInstance(WeatherRp5ListWrapper.class);
            Marshaller m = context.createMarshaller();
            m.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, true);

            // Wrapping our person data.
            WeatherRp5ListWrapper wrapper = new WeatherRp5ListWrapper();
            wrapper.setWeatherRp5(weatherRp5Data);

            // Marshalling and saving XML to the file.
            m.marshal(wrapper, file);

            // Save the file path to the registry.
            setWeatherRp5FilePath(file);
        } catch (Exception e) { // catches ANY exception
            Dialogs.create().title("Error")
                    .masthead("Could not save data to file:\n" + file.getPath())
                    .showException(e);
        }
    }
}