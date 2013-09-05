---
title: "Snippet: Copy a File"
---
	private static void copyFile(File sourceFile, File destFile) throws IOException {
		if (sourceFile == null) {
			throw new IllegalArgumentException();
		}
		if (destFile == null) {
			throw new IllegalArgumentException();
		}
	
		if (!destFile.exists()) {
			destFile.createNewFile();
		}
	
		FileChannel in = new FileInputStream(sourceFile).getChannel();
		try {
			FileChannel out = new FileOutputStream(destFile).getChannel();
			try {
				out.transferFrom(in, 0, in.size());
			} finally {
				out.close();
			}
		} finally {
			in.close();
		}
	}
