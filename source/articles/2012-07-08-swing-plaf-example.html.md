---
title: "Swing PLAF Example"
tags: swing,java,plaf
---
<p>One way to create a simple Swing PLAF it to sub-class an existing PLAF and override some if its option. The benefit of this approach is that is quick and simple. You choose what fonts and colours to override, and but fall back to the existing options if they’re not available.</p>

<p>Here's an example. It provides meta-data about the PLAF's name, and then overrides key defaults.</p>

	public class OverridingLookAndFeel extends MetalLookAndFeel {
	
		private static final Font font = new Font("Lucida Sans Unicode", Font.BOLD, 12);
		private static final ColorUIResource foreground = new ColorUIResource(100,25,0);
		private static final ColorUIResource background = new ColorUIResource(255,255,240);
	
		@Override
		public String getName() {
			return "OverridingLookAndFeel";
		}
	
		@Override
		public String getID() {
			return "OverridingLookAndFeel";
		}
	
		@Override
		public String getDescription() {
			return "Extends metal, changing a few new options";
		}
	
		@Override
		public boolean isNativeLookAndFeel() {
			return false;
		}
	
		@Override
		public boolean isSupportedLookAndFeel() {
			return true;
		}
	
		@Override
		protected void initComponentDefaults(UIDefaults table) {
			table.put("text", foreground);
			table.put("control", background);
			table.put("window", background);
	
			super.initComponentDefaults(table);
	
			table.put("Button.font", font);
			table.put("Button.foreground", foreground);
	
			final TreeSet<Object> objects = new TreeSet<Object>(new Comparator<Object>() {
				@Override
				public int compare(final Object o1, final Object o2) {
					return o1.toString().compareTo(o2.toString());
				}
			});
			objects.addAll(table.keySet());
			for (Object x : objects) {
				try {
					System.out.println(new Formatter().format("%40s = %s", x, table.get(x)));
				} catch(Exception e) {
					System.err.println(e);
				}
			}
		}
	}

<p>A good way to test a PLAF (or just preview components in a theme) is by displaying a frame with common components on it.</p>

	public class DemoFrame extends JFrame {
	
	    public DemoFrame() {
	        setTitle("Swing Preview");
	
	        // use name to target the frame
	        getContentPane().setName("Frame");
	
	        JPanel panel1 = new JPanel();
	        JPanel panel2 = new JPanel();
	
	        final DefaultTableModel model = new DefaultTableModel(new String[]{"Key", "Value"},0);
	        for (Map.Entry<Object, Object> entry : UIManager.getDefaults().entrySet()) {
	           model.addRow(new Object[] {
	                   entry.getKey(), entry.getValue()
	           });
	        }
	        final JProgressBar bar1 = new JProgressBar() {{
	            setStringPainted(true);
	        }};
	        // animator for the progress bar
	        new Thread(new Runnable() {
	            @Override
	            public void run() {
	                while (true) {
	                    final int i = bar1.getValue() + 1;
	                    bar1.setValue(i % bar1.getMaximum());
	                    try {
	                        Thread.sleep(100);
	                    } catch (InterruptedException e) {
	                        Thread.currentThread().interrupt();
	                    }
	                }
	            }
	        }).start();
		    final List<? extends JComponent> components = Arrays.asList(
	                new JButton("Button") {{addActionListener(new ActionListener() {
	                    @Override
	                    public void actionPerformed(ActionEvent actionEvent) {
	                        JOptionPane.showMessageDialog(DemoFrame.this, "OptionPane");
	                    }
	                });}},
	                new JCheckBox("Checkbox") {{setSelected(true);}},
	                new JColorChooser(),
	                new JComboBox(new String[] {"ComboBox Item 0", "ComboBox Item 1", "ComboBox Item 2"}),
	                new JFileChooser("FileChooser"),
	                new JEditorPane() {{setText("EditorPane");}},
	                new JLabel("Label"),
	                new JList(new String[] {"List Item 0", "List Item 1", "List Item 2", "List Item 3"}) {{setSelectedIndex(1);}},
	                new JMenuBar(),
	                new JPasswordField("PasswordField"),
	                bar1,
				    new JProgressBar() {{
				        setIndeterminate(true);
				        setStringPainted(true);
				        setString("ProgressBar Indeterminate");
				    }},
	                new JRadioButton("RadioButton") {{setSelected(true);}},
	                new JSlider(),
	                new JSpinner(new SpinnerDateModel()),
	                new JScrollPane(new JTable(model)),
	                new JTextArea("TextArea"),
	                new JTextField("TextField"),
	                new JToggleButton("ToggleButton"),
	                new JToolBar(),
	                new JTree()
	        );
	
	        for (JComponent c : components) {
	            final boolean l = c instanceof JColorChooser || c instanceof JFileChooser || c instanceof JScrollPane;
	            final JPanel panel = l ? panel2 : panel1;
		        c.setToolTipText(c.toString());
	            panel.add(c);
	        }
	
	        add(new JSplitPane(JSplitPane.VERTICAL_SPLIT, new JScrollPane(panel1), new JScrollPane(panel2)));
	
	        pack();
	    }
	}

<p>And a short app.</p>

	public static void main(String[] args) throws Exception {
	    SwingUtilities.invokeAndWait(new Runnable() {
	        @Override
	        public void run() {
	        try {
	                UIManager.setLookAndFeel(new OverridingLookAndFeel());
	                final DemoFrame f = new DemoFrame();
	                f.addWindowListener(new WindowAdapter() {
	                    @Override
	                    public void windowClosing(WindowEvent e) {
	                        System.exit(0);
	                    }
	                });
	                f.setVisible(true);
	            } catch (Exception e) {
	                throw new RuntimeException(e);
	            }
	        }
	   });
	}

<p>The benefits of this approach is that you can get up and running fast, the main con being that you need to carefully choose an existing PLAF to modify, as the more you vary yours from the PLAF, the more work you'll create, ultimately you may find that the overridden PLAF is limiting.</p>

<p>The code for this is <a href="https://github.com/alexec/swing-synth-plaf-template">on Github</a>.</p>

<p>If you're interested in look and feel, then you may want to read <a href="/tutorial-swing-synth-plaf-template-part-1">my example of doing a Swing Synth based PLAF.</p>
