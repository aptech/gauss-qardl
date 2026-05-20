# Release Checklist

Use this checklist before publishing a GAUSS QARDL release.

## Citation And License

- Confirm `CITATION.cff`, `CITATION.md`, and
  `docs/QARDL_RELEASE_ARTICLE.md` match the release version, date, URL, and
  preferred citation.
- Finalize the public license before publishing. If the intended policy is open
  GAUSS use without direct ports to R, MATLAB, Python, or other languages,
  review `docs/LICENSING_OPTIONS.md`, add the final root `LICENSE`, and ensure
  `package.json` uses the same license identifier.

## Release Steps

1. Confirm `package.json`, `CHANGELOG.md`, `CITATION.cff`,
   `CITATION.md`, and the intended artifact name use the same release version.
2. Build and verify the GAUSS application package:

   ```powershell
   powershell -ExecutionPolicy Bypass -File scripts\build_package.ps1 -Force
   ```

3. Run the full source, benchmark, example, artifact, and installed-package
   release gate after installing the rebuilt package:

   ```powershell
   powershell -ExecutionPolicy Bypass -File scripts\run_release_verification.ps1
   ```

   To have the script install the rebuilt artifact into the default GAUSS
   package directory before running the installed-package test, add
   `-InstallArtifact`. This replaces the existing `qardl` package under
   `C:\gauss26\pkgs` unless `-GaussHome` or `-InstallRoot` points elsewhere.

4. If running the installed-package gate manually:

   ```powershell
   & 'C:\gauss26\tgauss.exe' -nb -b -x -e 'd="C:\\path\\to\\gauss-qardl\\tests"; chdir ^d; run package_public_api.e;'
   ```

5. Confirm the release zip is named for the package version, for example
   `qardl 3.0.1.zip`.
6. Update `CHANGELOG.md`, `README.md`, and `GOLD_STANDARD_TODO.md`.
7. Attach the zip to the GitHub Release or commit it only if release artifacts
   are intentionally tracked in this repository.
