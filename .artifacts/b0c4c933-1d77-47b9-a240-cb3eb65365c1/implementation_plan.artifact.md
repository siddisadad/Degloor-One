# UI Enhancement Plan: Jobs Feature

This plan aims to modernize and polish the UI for the "Jobs" feature in the Degloor One app, including the Job Marketplace and Job Management screens.

## Proposed Changes

### [Component] Job Card

Create a reusable and visually appealing Job Card component to replace the inline list items.

#### [NEW] [job_card_widget.dart](file:///A:/Workspace/Degloor-One/lib/components/job_card/job_card_widget.dart)
- Implement a modern card design with:
    - Clear typography for Job Title and Business Name.
    - Styled badges for Job Type (Full-time, Part-time, etc.).
    - Icon-based indicators for Salary.
    - Integrated "Apply" or "View Details" button.
    - Support for both light and dark modes using `FlutterFlowTheme`.

### [Component] Apply Job Sheet

Create a dedicated component for the job application process.

#### [NEW] [apply_job_sheet_widget.dart](file:///A:/Workspace/Degloor-One/lib/components/apply_job_sheet/apply_job_sheet_widget.dart)
- A clean bottom-sheet UI for entering application details.
- Better input validation and success feedback.

### [Feature] Jobs Marketplace Enhancement

#### [MODIFY] [jobs_marketplace_widget.dart](file:///A:/Workspace/Degloor-One/lib/pages/jobs_marketplace/jobs_marketplace_widget.dart)
- Replace custom list item implementation with the new `JobCard`.
- Modernize the Search Bar (prefix icons, rounded corners, subtle shadows).
- Polish the Job Type filter chips (active/inactive states, animations).
- Add `AnimatedList` or simple entry animations for job items.

### [Feature] Manage Jobs Enhancement

#### [MODIFY] [manage_jobs_widget.dart](file:///A:/Workspace/Degloor-One/lib/pages/manage_jobs/manage_jobs_widget.dart)
- Use the `JobCard` component for consistency.
- Replace the basic `showDialog` for posting jobs with a more refined `ModalBottomSheet` or a dedicated screen.
- Improve the "Applicants" view with better status indicators and contact buttons.

## Verification Plan

### Manual Verification
- Verify the new `JobCard` looks consistent and elegant in both Light and Dark modes.
- Test the Search and Filter functionality in the Marketplace.
- Verify the Application flow (Bottom Sheet) works as expected.
- Check the "Manage Jobs" screen for visual consistency.
