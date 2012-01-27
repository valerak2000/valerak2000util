package org.library.swt;

import java.io.PrintWriter;
import java.lang.reflect.Constructor;
import java.lang.reflect.Method;

import org.eclipse.swt.SWT;
import org.eclipse.swt.custom.CBanner;
import org.eclipse.swt.custom.CLabel;
import org.eclipse.swt.custom.CTabFolder;
import org.eclipse.swt.custom.CTabItem;
import org.eclipse.swt.custom.PopupList;
import org.eclipse.swt.custom.SashForm;
import org.eclipse.swt.custom.StyledText;
import org.eclipse.swt.events.ControlListener;
import org.eclipse.swt.events.KeyListener;
import org.eclipse.swt.events.PaintListener;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.events.ShellAdapter;
import org.eclipse.swt.events.ShellEvent;
import org.eclipse.swt.graphics.Device;
import org.eclipse.swt.graphics.Image;
import org.eclipse.swt.graphics.Rectangle;
import org.eclipse.swt.layout.FillLayout;
import org.eclipse.swt.layout.FormAttachment;
import org.eclipse.swt.layout.FormData;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Canvas;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Control;
import org.eclipse.swt.widgets.CoolBar;
import org.eclipse.swt.widgets.CoolItem;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Group;
import org.eclipse.swt.widgets.Item;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Layout;
import org.eclipse.swt.widgets.Link;
import org.eclipse.swt.widgets.Menu;
import org.eclipse.swt.widgets.MenuItem;
import org.eclipse.swt.widgets.MessageBox;
import org.eclipse.swt.widgets.ProgressBar;
import org.eclipse.swt.widgets.Scale;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Slider;
import org.eclipse.swt.widgets.Spinner;
import org.eclipse.swt.widgets.TabFolder;
import org.eclipse.swt.widgets.TabItem;
import org.eclipse.swt.widgets.Text;
import org.eclipse.swt.widgets.ToolBar;
import org.eclipse.swt.widgets.ToolItem;
import org.eclipse.swt.widgets.Tracker;
import org.eclipse.swt.widgets.Widget;

// TODO: add JavaDoc

/**
 * Base class for standalone SWT aplications.
 *
 * @author barryf
 */
abstract public class BasicApplication extends Composite {
    protected Shell shell;

    protected abstract class XSelectionAdapter implements SelectionListener {
        public void widgetDefaultSelected(SelectionEvent e) {
            widgetSelected(e);
        }
    }

    /** Configure the form of the container */
    protected static void configureLayout(Control c, FormAttachment left, FormAttachment top, FormAttachment right, FormAttachment bottom) {
        FormData fd = new FormData();
        if (left != null) {
            fd.left = left;
        }
        if (top != null) {
            fd.top = top;
        }
        if (right != null) {
            fd.right = right;
        }
        if (bottom != null) {
            fd.bottom = bottom;
        }
        c.setLayoutData(fd);
    }

    /** Indent lines */
    protected void indent(PrintWriter pw, int level) {
        for (int i = 0; i < level; i++) {
            pw.print("    ");
        }
    }

    /** Find and invoke a zero-arg method */
    protected Object invoke(String name, Widget c) {
        Object res = null;
        try {
            Method m = c.getClass().getMethod(name, null);
            res = m.invoke(c, null);
        }
        catch (Exception e) {
        }
        return res;
    }
    /** Get the Items asociatated with a widget */
    protected Item[] getItems(Widget w) {
        Object o = invoke("getItems", w);
        return o instanceof Item[] ? (Item[])o : null;
    }
    /** Get the String Items asociatated with a widget */
    protected String[] getStringItems(Widget w) {
        Object o = invoke("getItems", w);
        return o instanceof String[] ? (String[])o : null;
    }
    /** Get the Controls asociatated with a widget */
    protected Control[] getChildren(Widget w) {
        return (Control[])invoke("getChildren", w);
    }
    /** Get the Shells asociatated with a widget */
    protected Shell[] getShells(Widget w) {
        return (Shell[])invoke("getShells", w);
    }

    /**
     * Output a GUI component tree on System.out
     * @param w Widget to print
     */
    public void displayTree(Widget w) {
        PrintWriter pw = new PrintWriter(System.out, true);
        displayTree(pw, w);
        pw.close();
    }
    /**
     * Output a GUI component tree
     * @param pw Target to print on
     * @param w Widget to print
     */
    public void displayTree(PrintWriter pw, Widget w) {
        displayTree(pw, w, 0, true);
    }
    /**
     * Output a GUI component tree
     * @param pw Target to print on
     * @param w Widget to print
     * @param level Indentation amount
     */
    public void displayTree(PrintWriter pw, Widget w, int level, boolean printLevel) {
        indent(pw, level);
        if (printLevel) {
			pw.print(level + ": ");
		}
        pw.println(w.toString());
        Item[] items = getItems(w);
        if (items != null && items.length > 0) {
            //indent(pw, level);
            //pw.println("Items:");
            for (int i = 0; i < items.length; i++) {
                displayTree(pw, items[i], level + 1, printLevel);
            }
        }

        Control[] children = getChildren(w);
        if (children != null && children.length > 0) {
            //indent(pw, level);
            //pw.println("Children:");
            for (int i = 0; i < children.length; i++) {
                displayTree(pw, children[i], level + 1, printLevel);
            }
        }

        Shell[] shells = getShells(w);
        if (shells != null && shells.length > 0) {
            indent(pw, level);
            pw.println("Child shells:");
            for (int i = 0; i < shells.length; i++) {
                displayTree(pw, shells[i], level + 1, printLevel);
            }
        }
    }

    /**
     * Constructor.
     */
    public BasicApplication(Shell parent) {
        this(parent, SWT.NONE);  // must always supply parent
    }
    /**
     * Constructor.
     */
    public BasicApplication(Shell shell, int style) {
        super(shell, style);   // must always supply parent and style
        this.shell = shell;
    }

    protected static final Class[] args = {};
    protected static final Class[] slType = {SelectionListener.class};

    /**
     * Register a method as an event callback routine;
     * Uses reflection to invoke
     *
     * @param w Widget to associate callback with
     * @param handler Class with mehto to handle request
     * @param handlerName Name of zero-arg method in handler to call
     */
    protected void registerCallback(final Widget w, final Object handler, final String handlerName) {
        try {
            Method m = w.getClass().getMethod("addSelectionListener", slType);
            m.invoke(w, new Object[] { new XSelectionAdapter() {
                                                public void widgetSelected(SelectionEvent e) {
                                                    try {
                                                        Method m = handler.getClass().getMethod(handlerName, args);
                                                        m.invoke(handler, null);
                                                    }
                                                    catch (Exception ex) {
                                                        ex.printStackTrace();
                                                    }
                                                }
                                            }});
        }
        catch (Exception e) {
        }
    }
    
    
    protected Image createImage(Device device, String path) {
    	return new Image(device, path);
    }

    /**
     * Create a Menu
     *
     * @param parent Containing Menu
     * @param enabled Item's enabled state
     */
    protected Menu createMenu(Menu parent, boolean enabled) {
        Menu m = new Menu(parent);
        m.setEnabled(enabled);
        return m;
    }

    /**
     * Create a Menu
     *
     * @param parent Containing MenuItem
     * @param enabled Item's enabled state
     */
    protected Menu createMenu(MenuItem parent, boolean enabled) {
        Menu m = new Menu(parent);
        m.setEnabled(enabled);
        return m;
    }

    /**
     * Create a Menu
     *
     * @param parent Containing Shell
     * @param style Item's style
     */
    protected Menu createMenu(Shell parent, int style) {
        Menu m = new Menu(parent, style);
        return m;
    }
    /**
     * Create a Menu
     *
     * @param parent Containing Shell
     * @param style Item's style
     * @param container Containing MenuItem
     * @param enabled Item's enabled state
     */
    protected Menu createMenu(Shell parent, int style, MenuItem container, boolean enabled) {
        Menu m = createMenu(parent, style);
        m.setEnabled(enabled);
        container.setMenu(m);
        return m;
    }

    /**
     * Create a popup Menu
     *
     * @param parent Owning Shell
     */
    protected Menu createPopupMenu(Shell shell) {
        Menu m = new Menu(shell, SWT.POP_UP);
        shell.setMenu(m);
        return m;
    }

    /**
     * Create a popup Menu
     *
     * @param parent Owning Shell
     * @param owner Owning Control
     */
    protected Menu createPopupMenu(Shell shell, Control owner) {
        Menu m = createPopupMenu(shell);
        owner.setMenu(m);
        return m;
    }

    /**
     * Create a MenuItem
     *
     * @param parent Containing menu
     * @param style Item's style
     * @param text Item's text (optional: null)
     * @param icon Item's icon (optional: null)
     * @param accel Item's accelerator (optional: &lt;0)
     * @param enabled Item's enabled state
     * @param callback Name of zero-arg method to call
     */
    protected MenuItem createMenuItem(Menu parent, int style, String text, Image icon, int accel, boolean enabled, String callback) {
        MenuItem mi = new MenuItem(parent, style);
        if (text != null) {
            mi.setText(text);
        }
        if (icon != null) {
            mi.setImage(icon);
        }
        if (accel != -1) {
            mi.setAccelerator(accel);
        }
        mi.setEnabled(enabled);
        if (callback != null) {
            registerCallback(mi, this, callback);
        }
        return mi;
    }

    protected PopupList createPopupList(Shell parent, int style, int minWidth, String[] items) {
        PopupList pl = new PopupList(parent, style);
        if (minWidth >= 0 ) {
            pl.setMinimumWidth(minWidth);
        }
        if (items != null) {
            pl.setItems(items);
        }
        return pl;
    }
    protected PopupList createPopupList(Shell parent, int minWidth, String[] items) {
        return createPopupList(parent, SWT.NONE, minWidth, items);
    }

    protected SashForm createSashForm(Composite parent, int style) {
        SashForm sf = new SashForm(parent, style);
        return sf;
    }
    protected SashForm createVSashForm(Composite parent) {
        return createSashForm(parent, SWT.VERTICAL);
    }
    protected SashForm createHSashForm(Composite parent) {
        return createSashForm(parent, SWT.HORIZONTAL);
    }

    protected Slider createSlider(Composite parent, int style, int min, int current, int max, int inc, int pageinc, int thumb, String callback) {
        Slider s = new Slider(parent, style);
        if (min >= 0) {
            s.setMinimum(min);
        }
        if (max >= 0) {
            s.setMaximum(max);
        }
        if (current >= 0) {
            s.setSelection(current);
        }
        if (inc >= 1) {
            s.setIncrement(inc);
        }
        if (pageinc >= 1) {
            s.setPageIncrement(pageinc);
        }
        if (thumb >= 1) {
            s.setThumb(thumb);
        }
        if (callback != null) {
            registerCallback(s, this, callback);
        }
        return s;
    }
    protected Slider createVSlider(Composite parent, int min, int current, int max, int inc, int pageinc, int thumb, String callback) {
        return createSlider(parent, SWT.VERTICAL, min, current, max, inc, pageinc, thumb, callback);
    }
    protected Slider createHSlider(Composite parent, int min, int current, int max, int inc, int pageinc, int thumb, String callback) {
        return createSlider(parent, SWT.HORIZONTAL, min, current, max, inc, pageinc, thumb, callback);
    }

    protected Spinner createSpinner(Composite parent, int style, int min, int current, int max, int inc, int pageinc, String callback) {
        Spinner s = new Spinner(parent, style);
        if (min >= 0) {
            s.setMinimum(min);
        }
        if (max >= 0) {
            s.setMaximum(max);
        }
        if (current >= 0) {
            s.setSelection(current);
        }
        if (inc >= 1) {
            s.setIncrement(inc);
        }
        if (pageinc >= 1) {
            s.setPageIncrement(pageinc);
        }
        if (callback != null) {
            registerCallback(s, this, callback);
        }
        return s;
    }
    
    protected Scale createScale(Composite parent, int style, int min, int current, int max, int inc, int pageinc) {
        Scale s = new Scale(parent, style);
        if (min >= 0) {
            s.setMinimum(min);
        }
        if (max >= 0) {
            s.setMaximum(max);
        }
        if (current >= 0) {
            s.setSelection(current);
        }
        if (inc >= 1) {
            s.setIncrement(inc);
        }
        if (pageinc >= 1) {
            s.setPageIncrement(pageinc);
        }
        return s;
    }
    protected Scale createVScale(Composite parent, int min, int current, int max, int inc, int pageinc) {
        return createScale(parent, SWT.VERTICAL, min, current, max, inc, pageinc);
    }
    protected Scale createHScale(Composite parent, int min, int current, int max, int inc, int pageinc) {
        return createScale(parent, SWT.HORIZONTAL, min, current, max, inc, pageinc);
    }

    protected ProgressBar createProgressBar(Composite parent, int style, int min, int current, int max) {
        ProgressBar pb = new ProgressBar(parent, style);
        if (min >= 0) {
            pb.setMinimum(min);
        }
        if (max >= 0) {
            pb.setMaximum(max);
        }
        if (current >= 0) {
            pb.setSelection(current);
        }
        return pb;
    }
    protected ProgressBar createVProgressBar(Composite parent, int min, int current, int max) {
        return createProgressBar(parent, SWT.VERTICAL, min, current, max);
    }
    protected ProgressBar createHProgressBar(Composite parent, int min, int current, int max) {
        return createProgressBar(parent, SWT.HORIZONTAL, min, current, max);
    }

    protected Label createLabel(Composite parent, String text, Image icon, int style) {
        Label l = new Label(parent, style);
        if (text != null) {
            l.setText(text);
        }
        if (icon != null) {
            l.setImage(icon);
        }
        return l;
    }
    protected Label createLabel(Composite parent, String text, Image icon) {
        return createLabel(parent, text, icon, SWT.LEFT);
    }
    protected Label createLabel(Composite parent, String text) {
        return createLabel(parent, text, null);
    }

    protected CLabel createCLabel(Composite parent, String text, Image icon, int style) {
        CLabel l = new CLabel(parent, style);
        if (text != null) {
            l.setText(text);
        }
        if (icon != null) {
            l.setImage(icon);
        }
        return l;
    }
    protected CLabel createCLabel(Composite parent, String text, Image icon) {
        return createCLabel(parent, text, icon, SWT.LEFT);
    }
    protected CLabel createCLabel(Composite parent, String text) {
        return createCLabel(parent, text, null);
    }

    protected Button createButton(Composite parent, int style, String text, Image icon, SelectionListener listener) {
        Button b = new Button(parent, style);
        if (text != null) {
            b.setText(text);
        }
        if (icon != null) {
            b.setImage(icon);
        }
        if (listener != null) {
            b.addSelectionListener(listener);
        }
        return b;
    }

    protected Button createButton(Composite parent, int style, String text, Image icon, String callback) {
        Button b = new Button(parent, style);
        if (text != null) {
            b.setText(text);
        }
        if (icon != null) {
            b.setImage(icon);
        }
        if (callback != null) {
            registerCallback(b, this, callback);
        }
        return b;
    }

    protected Button createPushButton(Composite parent, String text, Image icon, String callback) {
        return createButton(parent, SWT.PUSH, text, icon, callback);
    }
    protected Button createPushButton(Composite parent, String text, String callback) {
        return createButton(parent, SWT.PUSH, text, null, callback);
    }

    protected Button createCheckBox(Composite parent, String text, Image icon, String callback) {
        return createButton(parent, SWT.CHECK, text, icon, callback);
    }
    protected Button createCheckBox(Composite parent, String text, Image icon) {
        return createCheckBox(parent, text, icon, null);
    }
    protected Button createCheckBox(Composite parent, String text) {
        return createCheckBox(parent, text, null);
    }

    protected TabFolder createTabFolder(Composite parent, int style) {
        return new TabFolder(parent, style);
    }
    protected TabItem createTabItem(TabFolder parent, int style, String text, Image icon, Control ctl) {
        TabItem ti = new TabItem(parent, style);
        if (text != null) {
            ti.setText(text);
        }
        if (icon != null) {
            ti.setImage(icon);
        }
        if (ctl != null) {
            ti.setControl(ctl);
        }
        return ti;
    }
    protected TabItem createTabItem(TabFolder parent, String text, Image icon, Control ctl) {
        return createTabItem(parent, SWT.NONE, text, icon, ctl);
    }

    protected CTabFolder createCTabFolder(Composite parent, int style) {
        return new CTabFolder(parent, style);
    }
    protected CTabItem createCTabItem(CTabFolder parent, int style, String text, Image icon, Control ctl) {
        CTabItem ti = new CTabItem(parent, style);
        if (text != null) {
            ti.setText(text);
        }
        if (icon != null) {
            ti.setImage(icon);
        }
        if (ctl != null) {
            ti.setControl(ctl);
        }
        return ti;
    }
    protected CTabItem createCTabItem(CTabFolder parent, String text, Image icon, Control ctl) {
        return createCTabItem(parent, SWT.NONE, text, icon, ctl);
    }

    protected Canvas createCanvas(Composite parent, int style, PaintListener pl) {
        Canvas c =  new Canvas(parent, style);
        if (pl != null) {
            c.addPaintListener(pl);
        }
        return c;
    }
    protected Canvas createCanvas(Composite parent, PaintListener pl) {
        return createCanvas(parent, SWT.NONE, pl);
    }

    protected Composite createComposite(Composite parent, int style, Layout layout) {
        Composite c =  new Composite(parent, style);
        if (layout != null) {
            c.setLayout(layout);
        }
        return c;
    }
    protected Composite createComposite(Composite parent, Layout layout) {
        return createComposite(parent, SWT.NONE, layout);
    }

    protected Group createGroup(Composite parent, int style, String text, Layout layout) {
        Group g = new Group(parent, style);
        if (text != null) {
            g.setText(text);
        }
        if (layout != null) {
            g.setLayout(layout);
        }
        return g;
    }
    protected Composite createGroup(Composite parent, String text, Layout layout) {
        return createGroup(parent, SWT.NONE, text, layout);
    }

    protected StyledText createStyledText(Composite parent, int style) {
        StyledText st = new StyledText(parent, style);
        return st;
    }

    protected Text createText(Composite parent, int style) {
        Text t = new Text(parent, style);
        return t;
    }

    protected ToolBar createVToolBar(Composite parent, int style) {
    	return new ToolBar(parent, style | SWT.VERTICAL);
    }

    protected ToolBar createHToolBar(Composite parent, int style) {
    	return new ToolBar(parent, style | SWT.HORIZONTAL);
    }
    
    protected ToolItem createToolItem(ToolBar bar, int style, String text, Image image, String tooltip, SelectionListener listener) {
    	if (image != null && (text == null && tooltip == null)) {
			throw new IllegalArgumentException("image only items require a tool tip");
		}
    	ToolItem ti = new ToolItem(bar, style);
    	if (image != null) {
			ti.setImage(image);
		}
    	else {
        	if (text != null) {
    			ti.setText(text);
    		}
    	}
    	if (tooltip != null) {
			ti.setToolTipText(tooltip);
		}
    	if (listener != null) {
        	ti.addSelectionListener(listener);
		}
    	return ti;
    }

    protected CoolBar createCoolBar(Composite parent, int style) {
    	return new CoolBar(parent, style);
    }
    
    protected CoolItem createCoolItem(CoolBar bar, int style, String text, Image image, SelectionListener listener) {
    	CoolItem ci = new CoolItem(bar, style);
    	if (text != null) {
			ci.setText(text);
		}
    	if (image != null) {
			ci.setImage(image);
		}
    	return ci;
    }
    
    protected Link createLink(Composite parent, String text, SelectionListener listener) {
    	Link l = new Link(parent, SWT.NONE);
    	if (text != null) {
			l.setText(text);
		}
    	if (listener != null) {
        	l.addSelectionListener(listener);
		}
    	//l.setEnabled(true);
    	return l;
    }
    
    protected CBanner createCBanner(Composite parent) {
    	return new CBanner(parent, SWT.NONE);
    }
    
    protected Tracker createTracker(Composite parent, int style) {
    	return createTracker(parent, style, null, null);
    }
    protected Tracker createTracker(Composite parent, int style, ControlListener cl, KeyListener kl) {
    	Tracker t = new Tracker(parent, style);
    	if (cl != null) {
			t.addControlListener(cl);
		}
    	if (kl != null) {
			t.addKeyListener(kl);
		}
    	return t;
    }
    
    
    /** Create the GUI */
    protected void createGui(String[] args) {
        setLayout(new FillLayout());

        shell.addShellListener(new ShellAdapter() {
                public void shellClosed(ShellEvent e) {
                    MessageBox mb = new MessageBox(shell, SWT.ICON_QUESTION | SWT.OK | SWT.CANCEL);
                    mb.setText("Confirm Exit");
                    mb.setMessage("Are you sure you want to exit?");
                    int rc = mb.open();
                    e.doit = rc == SWT.OK;
                }
        });
        completeGui(args);
    }

    /* Make my Shell centered on the Display */
    public static void centerShell(Shell shell) {
        Display d = shell.getDisplay();
        Rectangle db = d.getBounds();
        Rectangle sb = shell.getBounds();
        int xoffset = (db.width - sb.width) / 2;
        int yoffset = (db.height - sb.height) / 2;
        shell.setLocation(xoffset, yoffset);
    }

    /** Allow subclasses to complete the GUI */
    protected void completeGui(String[] args) {
    }

    /** Allow subclasses to initialize the GUI */
    protected void initGui() {
    }

    /**
     * Run the application.
     *
     * @param appname name of the class to construct and run
     * @param title Shell title message
     * @param style Content style
     * @param width Shell width
     * @param height Shell height
     * @param args Any command line arguments
     */
    public static void run(String appName, String title, int style, int width, int height, String[] args) {
        // the display allows access to the host display device
        final Display display = new Display();
        try {
            // the shell is the top level window (AKA frame)
            final Shell shell = new Shell(display);
            shell.setText(title);
            shell.setLayout(new FillLayout());

            // add user component
            Class clazz = Class.forName(appName);
            Constructor ctor = clazz.getConstructor(new Class[] {Shell.class, Integer.TYPE});
            BasicApplication app = (BasicApplication)ctor.newInstance(new Object[] {shell, new Integer(style)});
            app.createGui(args);
            app.initGui();

            shell.setSize(width, height);
            centerShell(shell);
            shell.open();       // open shell for user access

            // process all user input events until the shell is disposed (i.e., closed)
            while ( !shell.isDisposed()) {
                if (!display.readAndDispatch()) {  // process next message
                    display.sleep();              // wait for next message
                }
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        display.dispose();  // must always clean up
    }
}
