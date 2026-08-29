# Asset provenance

What each visual asset is, where it came from, and whether it is cleared for
redistribution. Incomplete rows are stated as incomplete rather than assumed
clear.

| File | Dimensions | Origin | Cleared to redistribute |
|---|---|---|---|
| `cover.png` | 1942x809 | Supplied by the maintainer. **The generation method is not recorded**, and the file carries no metadata chunks that would show it. If it was model-generated, or uses a licensed typeface or icon set, that has to be established before the repository is made public | **Not established** |
| `social-preview.png` | 1280x640 | Derived from `cover.png` by the maintainer's tooling: resized to 1280 wide and padded to 1280x640 on `#0A0A0A`. Carries ImageMagick timestamp chunks only | Follows `cover.png` |

## Before this repository goes public

Confirm and record for `cover.png`: how it was produced, the terms of any tool
that produced it, and the licence of any embedded typeface or icon set. Until
that row says yes, `NOTICE` makes no MIT rights claim over either image, and
that is deliberate rather than an oversight.

A retired earlier pair of generated SVG banners was removed in 0.2.0 and is not
part of the distribution.
